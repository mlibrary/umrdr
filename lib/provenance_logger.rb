# lib/custom_logger.rb
class ProvenanceLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)} #{severity} User: #{Rails.configuration.user_email} #{msg}\n"
  end
end

#logfile = File.open("#{Rails.root}/log/custom.log", 'a')  # create log file
logfile = File.open(Rails.root.join('log', 'provenance.log'), 'a')  # create log file
logfile.sync = true  # automatically flushes data to file
PROV_LOGGER = ProvenanceLogger.new(logfile)  # constant accessible anywhere
