#require 'clamav/client'

# An AV class that streams the file to an already-running
# clamav daemon
class UMichClamAVDaemonScanner < Hydra::Works::VirusScanner


  # standard umich clamav configuration (from /etc/clamav/clamav.conf)

  CONNECTION_TYPE = :tcp
  PORT            = 3310
  MACHINE         = '127.0.0.1'

  CHUNKSIZE = 4096

  # Check to see if we can connect to the configured
  # ClamAV daemon
  def alive?
    client.execute(ClamAV::Commands::PingCommand.new)
    true
  rescue Errno::ECONNREFUSED
    false
  end

  # Check to see if the file passed on `#new` is infected
  # Reports `true` if a virus is found, `false` for all other
  # states (no virus or some sort of error)
  def infected?
    file_io = File.open(file, 'rb')
    resp    = scan(file_io)
    case resp
    when ClamAV::SuccessResponse
      info "Clean virus check for '#{file}'"
      false
    when ClamAV::VirusResponse
      warn "Virus #{resp.virus_name} found in file '#{file}'"
      true
    when ClamAV::ErrorResponse
      warn "ClamAV error: #{resp.error_str} for file #{file}. File not scanned!"
      true # err on the side of trust? Need to think about this
    else
      warn "ClamAV response unknown type '#{resp.class}': #{resp}. File not scanned!"
      true
    end
  end

  # Do the scan by streaming to the daemon
  # @param [#read] io The IO stream (probably an open file) to read from
  # @return A ClamAV::*Response object
  def scan(io)
    cmd = UMInstreamScanner.new(io, CHUNKSIZE)
    client.execute(cmd)
  end




  private
  # Set up logging for the clamav daemon scanner
  def info(msg)
    ActiveFedora::Base.logger.info(msg) if ActiveFedora::Base.logger
  end

  def warning(msg)
    ActiveFedora::Base.logger.warn(msg) if ActiveFedora::Base.logger
  end

end



# Stream a file to the AV scanner in chucks to avoid
# reading it all into memory. Internal to how
# ClamAV::Client works
class UMInstreamScanner < ClamAV::Commands::InstreamCommand
  def call(conn)
    conn.write_request("INSTREAM")
    while(packet = @io.read(@max_chunk_size))
      scan_packet(conn, packet)
    end
    send_end_of_file(conn)
    av_return_status(conn)
  rescue => e
    ClamAV::ErrorResponse.new("Error sending data to ClamAV Daemon: #{e}")
  end

  def av_return_status(conn)
    get_status_from_response(conn.read_response)
  end

  def send_end_of_file(conn)
    conn.raw_write("\x00\x00\x00\x00")
  end

  def scan_packet(conn, packet)
    packet_size = [packet.size].pack("N")
    conn.raw_write("#{packet_size}#{packet}")
  end


end





# To use a virus checker other than ClamAV:
#   class MyScanner < Hydra::Works::VirusScanner
#     def infected?
#       my_result = Scanner.check_for_viruses(file)
#       [return true or false]
#     end
#   end
