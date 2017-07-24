if defined? ClamAV and !(ENV['CI'] == 'true')
  require "umich_clamav_daemon_scanner"
  Hydra::Works.default_system_virus_scanner = UMichClamAVDaemonScanner
  Rails.logger.info "Using ClamAV Daemon"
else
  Rails.logger.warn "No virus check in use."
end
