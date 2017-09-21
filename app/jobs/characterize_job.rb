class CharacterizeJob < ActiveJob::Base
  queue_as Hyrax.config.ingest_queue_name

  # @param [FileSet] file_set
  # @param [String] file_id identifier for a Hydra::PCDM::File
  # @param [String, NilClass] filepath the cached file within the Hyrax.config.working_path
  def perform(file_set, file_id, filepath = nil)
    filename = Hyrax::WorkingDirectory.find_or_retrieve(file_id, file_set.id, filepath)
    #Rails.logger.warn "File to characterize: " + filepath
    ## TO DO: put in a config file?
    ## nc files will can't be retrieved if they go through characterization.
    #if file_set.label.end_with?(".nc")
    #  if File.exist?(filepath)
    #    File.delete (filepath)
    #    Rails.logger.debug "Characterize file deleted: " + filepath
    #  end
    #  return
    #end
    unless file_set.characterization_proxy?
      error_msg = "#{file_set.class.characterization_proxy} was not found"
      Rails.logger.error error_msg
      raise LoadError, error_msg
    end
    begin
      Hydra::Works::CharacterizationService.run(file_set.characterization_proxy, filename)
      Rails.logger.debug "Ran characterization on "
            + "#{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"
      file_set.characterization_proxy.save!
      file_set.update_index
      file_set.parent.in_collections.each(&:update_index) if file_set.parent
    rescue Exception => e
      Rails.logger.error "create_derivatives(#{filename}) #{e.class}: #{e.message}"
    ensure
      # the create derivatives job will delete the input temp file
      CreateDerivativesJob.perform_later(file_set, file_id, filename)
    end
  end
end
