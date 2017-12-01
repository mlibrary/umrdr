include CharacterizationHelper

class CreateDerivativesJob < ActiveJob::Base
  queue_as Hyrax.config.ingest_queue_name

  # @param [FileSet] file_set
  # @param [String] file_id identifier for a Hydra::PCDM::File
  # @param [String, NilClass] filepath the cached file within the Hyrax.config.working_path
  def perform( file_set, file_id, filepath = nil, delete_input_file = true )
    CharacterizationHelper.create_derivatives( file_set, file_id, filepath, delete_input_file: delete_input_file )
  rescue Exception => e
    Rails.logger.error "CreateDerivativesJob.perform(#{file_set},#{file_id},#{filepath}) #{e.class}: #{e.message}"
    # filename = Hyrax::WorkingDirectory.find_or_retrieve(file_id, file_set.id, filepath)
    # Rails.logger.warn "Create derivatives for: #{filename}."
    # begin
    #   if file_set.video? && !Hyrax.config.enable_ffmpeg
    #     Rails.logger.info "Skipping video derivative job for file: #{filename}"
    #     return
    #   end
    #   threshold_file_size = Umrdr::Application.config.derivative_max_file_size
    #   if threshold_file_size > -1 && File.exist?(filename) && File.size(filename) > threshold_file_size
    #     human_readable = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert( threshold_file_size, precision: 3 )
    #     Rails.logger.info "Skipping file larger than #{human_readable} for create derivative job file: #{filename}"
    #     return
    #   end
    #   Rails.logger.debug "About to call create derivatives: #{filename}."
    #   file_set.create_derivatives(filename)
    #   Rails.logger.debug "Create derivatives successful: #{filename}."
    #   # Reload from Fedora and reindex for thumbnail and extracted text
    #   file_set.reload
    #   file_set.update_index
    #   file_set.parent.update_index if parent_needs_reindex?(file_set)
    #   Rails.logger.debug "Successful create derivative job for file: #{filename}"
  # rescue Exception => e
  #   Rails.logger.error "CreateDerivativesJob.perform(#{file_set},#{file_id},#{filepath}) #{e.class}: #{e.message}"
    # ensure
    #   #This is the last step in the process ( ingest job -> characterization job -> create derivative (last step))
    #   #So now it's safe to remove the file uploaded file.
    #   if File.exist?(filepath)
    #     File.delete (filepath)
    #     Rails.logger.info "Create derivatives file deleted: #{filepath}"
    #   end
    # end
  end

  # # If this file_set is the thumbnail for the parent work,
  # # then the parent also needs to be reindexed.
  # def parent_needs_reindex?(file_set)
  #   return false unless file_set.parent
  #   file_set.parent.thumbnail_id == file_set.id
  # end

end
