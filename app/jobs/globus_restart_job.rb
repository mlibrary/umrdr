class GlobusRestartJob < GlobusJob
  queue_as :globus_restart

  # @param [String] concern_id
  # @param [String, "Globus: "] log_prefix
  # @param [boolean, false] force_restart
  def perform( concern_id, log_prefix: "Globus: ", force_restart: false, user_email: nil )
    if force_restart
      @globus_log_prefix = "#{log_prefix}globus_restart_job"
      @globus_lock_file = GlobusJob.lock_file concern_id
      globus_unlock
    end
    user_email = nil
    ::GlobusCopyJob.perform_later( concern_id, user_email: user_email, log_prefix: log_prefix )
  end

end
