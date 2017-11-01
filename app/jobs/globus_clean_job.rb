class GlobusCleanJob < GlobusJob
  queue_as :globus_clean

  # @param [String] concern_id
  # @param [String, "Globus: "] log_prefix
  def perform( concern_id, log_prefix: "Globus: ", clean_download: false )
    @globus_log_prefix = "#{log_prefix}globus_clean_job(#{concern_id})"
    # TODO: delete prep files for given work and download files if indicated
  end

end