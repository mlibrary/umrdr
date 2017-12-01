
module CharacterizationHelper

  # @param [FileSet] file_set
  # @param [String] file_id identifier for a Hydra::PCDM::File
  # @param [String, NilClass] file_path the cached file within the Hyrax.config.working_path
  def self.characterize( file_set,
                         file_id,
                         file_path = nil,
                         delete_input_file: true,
                         continue_job_chain: true,
                         continue_job_chain_later: true )
    file_name = Hyrax::WorkingDirectory.find_or_retrieve( file_id, file_set.id, file_path )
    file_ext = File.extname file_set.label
    if Umrdr::Application.config.characterize_excluded_ext_set.has_key? file_ext
      Rails.logger.info "Skipping characterization of file with extension #{file_ext}: #{file_name}"
      perform_create_derivatives_job( file_set,
                                      file_id,
                                      file_name,
                                      delete_input_file: delete_input_file,
                                      continue_job_chain: continue_job_chain,
                                      continue_job_chain_later: continue_job_chain_later )
      return
    end
    unless file_set.characterization_proxy?
      error_msg = "#{file_set.class.characterization_proxy} was not found"
      Rails.logger.error error_msg
      raise LoadError, error_msg
    end
    begin
      proxy = file_set.characterization_proxy
      Hydra::Works::CharacterizationService.run( proxy, file_name )
      Rails.logger.debug "Ran characterization on #{proxy.id} (#{proxy.mime_type})"
      file_set.characterization_proxy.save!
      file_set.update_index
      file_set.parent.in_collections.each(&:update_index) if file_set.parent
    rescue Exception => e
      Rails.logger.error "CharacterizationHelper.create_derivatives(#{file_name}) #{e.class}: #{e.message}"
    ensure
      perform_create_derivatives_job( file_set,
                                      file_id,
                                      file_name,
                                      delete_input_file: delete_input_file,
                                      continue_job_chain: continue_job_chain,
                                      continue_job_chain_later: continue_job_chain_later )
    end
  end

  # @param [FileSet] file_set
  # @param [String] file_id identifier for a Hydra::PCDM::File
  # @param [String, NilClass] file_path the cached file within the Hyrax.config.working_path
  def create_derivatives( file_set, file_id, file_path = nil, delete_input_file: true )
    file_name = Hyrax::WorkingDirectory.find_or_retrieve( file_id, file_set.id, file_path )
    Rails.logger.warn "Create derivatives for: #{file_name}."
    begin
      file_ext = File.extname file_set.label
      if Umrdr::Application.config.derivative_excluded_ext_set.has_key? file_ext
        Rails.logger.info "Skipping derivative of file with extension #{file_ext}: #{file_name}"
        return
      end
      if file_set.video? && !Hyrax.config.enable_ffmpeg
        Rails.logger.info "Skipping video derivative job for file: #{file_name}"
        return
      end
      threshold_file_size = Umrdr::Application.config.derivative_max_file_size
      if threshold_file_size > -1 && File.exist?(file_name) && File.size(file_name) > threshold_file_size
        human_readable = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert( threshold_file_size, precision: 3 )
        Rails.logger.info "Skipping file larger than #{human_readable} for create derivative job file: #{file_name}"
        return
      end
      Rails.logger.debug "About to call create derivatives: #{file_name}."
      file_set.create_derivatives(file_name)
      Rails.logger.debug "Create derivatives successful: #{file_name}."
      # Reload from Fedora and reindex for thumbnail and extracted text
      file_set.reload
      file_set.update_index
      file_set.parent.update_index if parent_needs_reindex?(file_set)
      Rails.logger.debug "Successful create derivative job for file: #{file_name}"
      #delete_file( file_path, delete_file_flag: delete_input_file, msg_prefix: 'Create derivatives ' )
    rescue Exception => e
      Rails.logger.error "CharacterizationHelper.create_derivatives(#{file_set},#{file_id},#{file_path}) #{e.class}: #{e.message}"
    ensure
      #This is the last step in the process ( ingest job -> characterization job -> create derivative (last step))
      #So now it's safe to remove the file uploaded file.
      delete_file( file_path, delete_file_flag: delete_input_file, msg_prefix: 'Create derivatives ' )
    end
  end

  def self.delete_file( file_path, delete_file_flag: false, msg_prefix: '' )
    if delete_file_flag
      if File.exist? file_path
        File.delete file_path
        Rails.logger.debug "#{msg_prefix}file deleted: #{file_path}"
      end
    end
  end

  # If this file_set is the thumbnail for the parent work,
  # then the parent also needs to be reindexed.
  def parent_needs_reindex?(file_set)
    return false unless file_set.parent
    file_set.parent.thumbnail_id == file_set.id
  end

  def self.perform_create_derivatives_job( file_set,
                                           file_id,
                                           file_name,
                                           delete_input_file: true,
                                           continue_job_chain: true,
                                           continue_job_chain_later: true )
    if continue_job_chain
      if continue_job_chain_later
        CreateDerivativesJob.perform_later( file_set, file_id, file_name, delete_input_file )
      else
        CreateDerivativesJob.perform_now( file_set, file_id, file_name, delete_input_file )
      end
    else
      delete_file( file_path, delete_file_flag: delete_input_file, msg_prefix: 'Characterize ' )
    end
  end

end
