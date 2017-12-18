require 'thread'
require 'singleton'

module Umrdr

  class GlobusEra
    include Singleton

    attr_reader :era_file, :era_begin_timestamp, :era_file_base, :era_verbose, :previous_era_begin_timestamp

    @mutex = Thread::Mutex.new

    def initialize
      @era_verbose = true
      @era_begin_timestamp = Time.now.to_s
      @era_file_base = ".globus_era.#{Socket.gethostname}"
      #log "hostname=#{Socket.gethostname}" if era_verbose
      if Umrdr::Application.config.globus_enabled
        log "GlobusEra initializing at #{@era_begin_timestamp}" if era_verbose
        #@era_file = Tempfile.new( 'globus_era_', Umrdr::Application.config.globus_prep_dir )
        @era_file = Umrdr::Application.config.globus_prep_dir.join era_file_base
        log "GlobusEra era file: #{@era_file} -- #{@era_file.class}" if era_verbose
        read_previous_era_file
        File.open( @era_file, "w" ) { |out| out << @era_begin_timestamp << "\n" }
        at_exit { File.delete @era_file if File.exists? @era_file }
        log "GlobusEra initialized." if era_verbose
      else
        @era_file = nil
      end
    end

    def log( msg )
      if Rails.logger.nil?
        puts msg
      else
        Rails.logger.info msg
      end
    end

    def previous_era?
      !@previous_era_begin_timestamp.nil?
    end

    def read_previous_era_file
      # TODO: look for previous era file and store it in:
      @previous_era_begin_timestamp = nil
      if File.exists? @era_file
        timestamp = nil
        open( lock_file, 'r' ) { |f| timestamp = f.read.chomp! }
        @previous_era_begin_timestamp = timestamp
        puts "GlobusEra found previous GlobusEra #{@previous_era_begin_timestamp}"
      end
    end

    def read_token
      token = nil
      open( @era_file, 'r' ) { |f| token = f.read.chomp! }
      return token
    end

    def read_token_time
      timestamp = read_token
      Time.parse( timestamp )
    end

  end

end
