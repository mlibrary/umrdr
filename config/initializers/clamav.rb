if defined? ClamAV and !(ENV['CI'] == 'true')
  require "umich_clamav_daemon_scanner"
  c = UMichClamAVDaemonScanner.new("this would be a filename")
  if c.alive?
    Hydra::Works.default_system_virus_scanner = UMichClamAVDaemonScanner
    Rails.logger.info "Successfully connected to ClamAV Daemon"
  else
    Rails.logger.warn "Can't connect to ClamAV Daemon; skipping virus checks"
  end
  
end
