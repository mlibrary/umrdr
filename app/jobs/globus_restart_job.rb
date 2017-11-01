class GlobusRestartJob < GlobusJob
  queue_as :globus_restart

  # @param [String] concern_id
  # @param [String, "Globus: "] log_prefix
  # @param [boolean, false] force_restart
  def perform( concern_id, log_prefix: "Globus: ", force_restart: false )
    if force_restart
      @globus_log_prefix = "#{log_prefix}globus_restart_job"
      @globus_lock_file = globus_lock_file concern_id
      globus_unlock
    end
    ::GlobusCopyJob.perform_later( concern_id, log_prefix: log_prefix )
  end

end
