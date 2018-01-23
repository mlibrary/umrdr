
module TaskCharacterizationHelper

  # @param [FileSet] file_set
  # @param [String] repository_file_id identifier for a Hydra::PCDM::File
  # @param [String, NilClass] file_path the cached file within the Hyrax.config.working_path
  def self.characterize( file_set,
                         repository_file_id,
                         file_path = nil,
                         delete_input_file: true,
                         continue_job_chain: true,
                         continue_job_chain_later: true )
    file_name = Hyrax::WorkingDirectory.find_or_retrieve( repository_file_id, file_set.id, file_path )
    file_ext = File.extname file_set.label
    if Umrdr::Application.config.characterize_excluded_ext_set.has_key? file_ext
      Rails.logger.info "Skipping characterization of file with extension #{file_ext}: #{file_name}"
      perform_create_derivatives_job( file_set,
                                      repository_file_id,
                                      file_name,
                                      file_path,
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
      Rails.logger.error "CharacterizationHelper.create_derivatives(#{file_name}) #{e.class}: #{e.message} at #{e.backtrace[0]}"
    ensure
      perform_create_derivatives_job( file_set,
                                      repository_file_id,
                                      file_name,
                                      file_path,
                                      delete_input_file: delete_input_file,
                                      continue_job_chain: continue_job_chain,
                                      continue_job_chain_later: continue_job_chain_later )
    end
  end

  # @param [FileSet] file_set
  # @param [String] repository_file_id identifier for a Hydra::PCDM::File
  # @param [String, NilClass] file_path the cached file within the Hyrax.config.working_path
  def self.create_derivatives( file_set, repository_file_id, file_path = nil, delete_input_file: true )
    file_name = Hyrax::WorkingDirectory.find_or_retrieve( repository_file_id, file_set.id, file_path )
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
      Rails.logger.error "CharacterizationHelper.create_derivatives(#{file_set},#{repository_file_id},#{file_path}) #{e.class}: #{e.message} at #{e.backtrace[0]}"
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

  # @param [FileSet] file_set
  # @param [String] filepath the cached file within the Hyrax.config.working_path
  # @param [User] user
  # @option opts [String] mime_type
  # @option opts [String] filename
  # @option opts [String] relation, ex. :original_file
  def self.ingest( file_set, filepath, user, opts = {} )
    Rails.logger.debug "CharacterizationHelper.ingest(#{file_set},#{filepath},#{user},#{opts})"
    ## see require File.join(Gem::Specification.find_by_name("hyrax").full_gem_path, "app/jobs/ingest_file_job.rb")
    relation = opts.fetch(:relation, :original_file).to_sym

    # Wrap in an IO decorator to attach passed-in options
    local_file = Hydra::Derivatives::IoDecorator.new(File.open(filepath, "rb"))
    local_file.mime_type = opts.fetch(:mime_type, nil)
    local_file.original_filename = opts.fetch(:filename, File.basename(filepath))

    # Tell AddFileToFileSet service to skip versioning because versions will be minted by
    # VersionCommitter when necessary during save_characterize_and_record_committer.
    Hydra::Works::AddFileToFileSet.call(file_set,
                                        local_file,
                                        relation,
                                        versioning: false)

    # Persist changes to the file_set
    file_set.save!

    repository_file = file_set.send(relation)

    # Do post file ingest actions
    Hyrax::VersioningService.create(repository_file, user)

    update_total_file_size( file_set )#, log_prefix: "CharacterizationHelper.ingest()" )

    # # TODO: this is a problem, the file may not be available at this path on another machine.
    # # It may be local, or it may be in s3
    CharacterizeJob.perform_later( file_set, repository_file.id, filepath )
  rescue Exception => e
    Rails.logger.error "CharacterizationHelper.ingest(#{file_set},#{filepath},#{user},#{opts}) #{e.class}: #{e.message} at #{e.backtrace[0]}"
  end

  # If this file_set is the thumbnail for the parent work,
  # then the parent also needs to be reindexed.
  def self.parent_needs_reindex?(file_set)
    return false unless file_set.parent
    file_set.parent.thumbnail_id == file_set.id
  end

  def self.perform_create_derivatives_job( file_set,
                                           repository_file_id,
                                           file_name,
                                           file_path,
                                           delete_input_file: true,
                                           continue_job_chain: true,
                                           continue_job_chain_later: true )
    if continue_job_chain
      if continue_job_chain_later
        CreateDerivativesJob.perform_later( file_set, repository_file_id, file_name, delete_input_file )
      else
        CreateDerivativesJob.perform_now( file_set, repository_file_id, file_name, delete_input_file )
      end
    else
      delete_file( file_path, delete_file_flag: delete_input_file, msg_prefix: 'Characterize ' )
    end
  end

  def self.update_total_file_size( file_set, log_prefix: nil )
    Rails.logger.info "begin CharacterizationHelper.update_total_file_size"
    Rails.logger.debug "#{log_prefix} file_set.orginal_file.size=#{file_set.original_file.size}" unless log_prefix.nil?
    return if file_set.parent.nil?
    total = file_set.parent.total_file_size
    if total.nil? || 0 == total
      Rails.logger.debug "#{log_prefix}.file_set.parent.update_total_file_size!" unless log_prefix.nil?
      file_set.parent.update_total_file_size!
    else
      Rails.logger.debug "#{log_prefix}.file_set.parent.total_file_size_add_file_set!" unless log_prefix.nil?
      file_set.parent.total_file_size_add_file_set! file_set
    end
    Rails.logger.info "end CharacterizationHelper.update_total_file_size"
  rescue Exception => e
    Rails.logger.error "CharacterizationHelper.update_total_file_size(#{file_set}) #{e.class}: #{e.message} at #{e.backtrace[0]}"
  end

end
