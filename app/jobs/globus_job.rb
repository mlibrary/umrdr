class GlobusJob < ActiveJob::Base

  @@globus_enabled = Umrdr::Application.config.globus_enabled.freeze
  @@globus_token = Umrdr::Application.config.globus_era_file
  @@globus_base_file_name = Umrdr::Application.config.base_file_name.freeze
  @@globus_base_url = Umrdr::Application.config.globus_base_url.freeze
  @@globus_download_dir = Umrdr::Application.config.globus_download_dir.freeze
  @@globus_prep_dir = Umrdr::Application.config.globus_prep_dir.freeze

  def self.files_available?( concern_id )
    copy_complete? concern_id
  end

  def self.copy_complete?( concern_id )
    dir = @@globus_download_dir
    dir = dir + '/' unless dir.end_with? '/'
    dir = dir + files_target_file_name( concern_id )
    Dir.exists? dir
  end

  def self.external_url( id )
    "#{@@globus_base_url}#{files_target_file_name(id)}%2F"
  end

  def self.files_target_file_name( id )
    "#{@@globus_base_file_name}#{id}"
  end

  def self.files_prepping?( id )
    dir = @@globus_prep_dir
    dir = dir + '/' unless dir.end_with? '/'
    dir = dir + files_target_file_name( id )
    Dir.exists? dir
  end

  def self.token
    @@globus_token.path
  end

  def self.token_time
    File::birthtime @@globus_token.path
  end

  # @param [String] concern_id
  # @param [String, "Globus: "] log_prefix
  def perform( concern_id, log_prefix: "Globus: " )
    @globus_concern_id = concern_id
    @globus_log_prefix = log_prefix
    @globus_lock_file = globus_lock_file concern_id
  end

  protected

  def globus_acquire_lock?
    return false if globus_locked?
    globus_lock
  end

  def globus_copy_job_complete?( concern_id )
    Dir.exists? target_download_dir concern_id
  end

  def globus_error( msg )
    file = globus_error_file
    Rails.logger.debug "#{@globus_log_prefix} writing error message to #{file}"
    open( file, 'w' ) { |f| f << msg << "\n" }
    file
  end

  def globus_error_file
    target_file_name_env(@@globus_prep_dir, 'error', target_base_name( @globus_concern_id ) )
  end

  def globus_error_file_exists?( write_error_to_log: false )
    error_file = globus_error_file
    error_file_exists = false
    if File.exists? error_file
      if write_error_to_log
        msg = nil
        open( error_file, 'r' ) { |f| msg = f.read; msg.chomp! }
        Rails.logger.debug "#{@globus_log_prefix} error file contains: #{msg}"
      end
      error_file_exists = true
    end
    error_file_exists
  end

  def globus_error_reset
    file = globus_error_file
    File.delete file if File.exists? file
    true
  end

  def globus_job_complete
    file = globus_job_complete_file
    timestamp = Time.now.to_s
    open( file, 'w' ) { |f| f << timestamp << "\n" }
    globus_error_reset
    Rails.logger.debug "#{@globus_log_prefix} job complete at #{timestamp}"
    file
  end

  def globus_job_perform( concern_id: '', log_prefix: 'Globus: ', &globus_block )
    return unless @@globus_enabled
    @globus_concern_id = concern_id
    @globus_log_prefix = log_prefix
    @globus_lock_file = nil
    begin
      if globus_job_complete?
        Rails.logger.debug "#{@globus_log_prefix} skipping already complete globus job"
        return
      end
      @globus_lock_file = globus_lock_file @globus_concern_id
      Rails.logger.debug "#{@globus_log_prefix} lock file #{@globus_lock_file}"
    rescue Exception => e
      msg = "#{@globus_log_prefix} #{e.class}: #{e.message} at #{e.backtrace[0]}"
      Rails.logger.error msg
      globus_error msg
      return
    end
    return unless globus_acquire_lock?
    begin
      globus_error_reset
      globus_job_complete_reset
      globus_block.call
      @globus_lock_file = globus_unlock
      globus_job_complete
    rescue Exception => e
      msg = "#{@globus_log_prefix} #{e.class}: #{e.message} at #{e.backtrace[0]}"
      Rails.logger.error msg
      globus_error msg
    ensure
      globus_unlock
    end
  end

  def globus_job_complete_reset
    file = globus_job_complete_file
    File.delete file if File.exists? file
    true
  end

  def globus_lock
    lock_token = GlobusJob.token
    lock_file = globus_lock_file @globus_concern_id
    Rails.logger.debug "#{@globus_log_prefix} writing lock token #{lock_token} to #{lock_file}"
    open( lock_file, 'w' ) { |f| f << lock_token << "\n" }
    File.exists? lock_file
  end

  def globus_lock_file( id = '' )
    target_file_name_env(@@globus_prep_dir, 'lock', target_base_name( id ) )
  end

  def globus_locked?
    return false if globus_error_file_exists?( write_error_to_log: true )
    lock_file = globus_lock_file @globus_concern_id
    return false unless File.exists? lock_file
    current_token = GlobusJob.token
    lock_token = nil
    open( lock_file, 'r' ) { |f| lock_token = f.read.chomp! }
    rv = ( current_token == lock_token )
    Rails.logger.debug "#{@globus_log_prefix} testing token from #{lock_file}: current_token: #{current_token} == lock_token: #{lock_token}: #{rv}"
    rv
  end

  def globus_unlock
    return nil if @globus_lock_file.nil?
    return nil unless File.exists? @globus_lock_file
    Rails.logger.debug "#{@globus_log_prefix} unlock by deleting file #{@globus_lock_file}"
    File.delete @globus_lock_file
    nil
  end

  def target_base_name( id = '', prefix: '', postfix: '' )
    "#{prefix}#{@@globus_base_file_name}#{id}#{postfix}"
  end

  def target_download_dir( concern_id )
    target_dir_name( @@globus_download_dir, target_base_name( concern_id ) )
  end

  def target_dir_name( dir, subdir, mkdir: false )
    folder = dir
    folder = folder + '/' unless ( folder.end_with?( '/' ) || subdir.start_with?( '/' ) )
    folder = folder + subdir
    if mkdir
      Dir.mkdir(folder ) unless Dir.exists? folder
    end
    folder
  end

  def target_file_name( dir, filename, ext = '' )
    return filename + ext if dir.nil?
    folder = dir
    folder = folder + '/' unless  ( folder.end_with?( '/' ) || filename.start_with?( '/' ) )
    folder = folder + filename + ext
  end

  def target_file_name_env( dir, file_type, base_name )
    target_file_name( dir, ".#{Rails.env}.#{file_type}.#{base_name}" )
  end

  def target_prep_dir( concern_id, prefix: '', postfix: '', mkdir: false )
    subdir = target_base_name( concern_id, prefix: prefix, postfix: postfix )
    target_dir_name( @@globus_prep_dir, subdir, mkdir: mkdir )
  end

  def target_prep_tmp_dir( concern_id, prefix: '', postfix: '', mkdir: false )
    dir = target_prep_dir( concern_id, prefix: prefix, postfix: "#{postfix}_tmp" )
    if mkdir
      Dir.mkdir(dir ) unless Dir.exists? dir
    end
    dir
  end

end