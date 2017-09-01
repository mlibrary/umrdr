class CharacterizeJob < ActiveJob::Base
  queue_as Hyrax.config.ingest_queue_name

  # @param [FileSet] file_set
  # @param [String] file_id identifier for a Hydra::PCDM::File
  # @param [String, NilClass] filepath the cached file within the Hyrax.config.working_path
  def perform(file_set, file_id, filepath = nil)
    filename = Hyrax::WorkingDirectory.find_or_retrieve(file_id, file_set.id, filepath)
    #Rails.logger.warn "File to characterize: " + filepath

    # TODO: put in a config file?
    # nc files will can't be retrieved if they go through characterization.
    if file_set.label.end_with?(".nc")
      if File.exist?(filepath)
        File.delete (filepath)
        Rails.logger.debug "Characterize file deleted: " + filepath
      end
      return
    end

    raise LoadError, "#{file_set.class.characterization_proxy} was not found" unless file_set.characterization_proxy?
    Hydra::Works::CharacterizationService.run(file_set.characterization_proxy, filename)
    Rails.logger.debug "Ran characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"
    file_set.characterization_proxy.save!
    file_set.update_index
    file_set.parent.in_collections.each(&:update_index) if file_set.parent

    # TODO: Is this the right place? Want to prevent full text indexing.
    # TODO: put in a config file?
    # prevent derivatives of files with sizes over 100 megabytes
    if File.exist?(filepath) && filepath.size > 100_000_000
      File.delete(filepath)
      Rails.logger.warn "Characterize large file deleted: " + filepath
    end
    CreateDerivativesJob.perform_later(file_set, file_id, filename)
  end
end
