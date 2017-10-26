class GlobusRestartAllJob < GlobusJob
  queue_as :globus_restart_all

  # @param [String, "Globus: "] log_prefix
  def perform( log_prefix: "Globus: " )
    Rails.logger.debug "#{log_prefix}globus_restart_all_job starting..."
    globus_job_perform( concern_id: "Restart_All", log_prefix: "#{log_prefix}globus_restart_all_job" ) do
      Rails.logger.debug "#{@globus_log_prefix} begin restart all"
      concern_ids_to_restart = Hash.new()
      base_name = target_base_name ''
      prefix = target_file_name_env(nil,'lock', base_name ).to_s
      lock_file_re = Regexp.compile( '^' + prefix + '([0-9a-z-]+)' + '$' )
      #Rails.logger.debug "#{@globus_log_prefix} lock_file_re=#{lock_file_re}"
      prefix = target_file_name_env(nil,'error', base_name ).to_s
      error_file_re = Regexp.compile( '^' + prefix + '([0-9a-z-]+)' + '$' )
      prefix = target_file_name( nil, "#{Rails.env}_#{base_name}" ).to_s
      prep_dir_re = Regexp.compile( '^' + prefix + '([0-9a-z-]+)' + '$' )
      #Rails.logger.debug "#{@globus_log_prefix} prep_dir_re=#{prep_dir_re}"
      prep_tmp_dir_re = Regexp.compile( '^' + prefix + '([0-9a-z-]+)_tmp' + '$' )
      starts_with_path = "#{@@globus_prep_dir}#{File::SEPARATOR}"
      files = Dir.glob( "#{starts_with_path}*" )
      #Rails.logger.debug "#{@globus_log_prefix} files.size=#{files.size}"
      files.each do |f|
        #Rails.logger.debug "#{@globus_log_prefix} processing #{f}"
        f = f.slice( (starts_with_path.length)..(f.length) ) if f.starts_with? starts_with_path
        #Rails.logger.debug "#{@globus_log_prefix} processing #{f}"
        match = lock_file_re.match( f )
        if match
          #Rails.logger.debug "#{@globus_log_prefix} lock_file_re=#{lock_file_re} matched #{f}"
          concern_id = match[1]
          concern_ids_to_restart.store( concern_id, true )
          next
        end
        match = error_file_re.match( f )
        if match
          #Rails.logger.debug "#{@globus_log_prefix} lock_file_re=#{error_file_re} matched #{f}"
          concern_id = match[1]
          concern_ids_to_restart.store( concern_id, true )
          next
        end
        match = prep_dir_re.match( f )
        if match
          #Rails.logger.debug "#{@globus_log_prefix} prep_dir_re=#{prep_dir_re} matched #{f}"
          concern_id = match[1]
          concern_ids_to_restart.store( concern_id, true )
          next
        end
        match = prep_tmp_dir_re.match( f )
        if match
          #Rails.logger.debug "#{@globus_log_prefix} lock_file_re=#{prep_tmp_dir_re} matched #{f}"
          concern_id = match[1]
          concern_ids_to_restart.store( concern_id, true )
          next
        end
      end
      concern_ids_to_restart.keys.each do |concern_id|
        #Rails.logger.debug "#{@globus_log_prefix} restart copy job #{concern_id}"
        ::GlobusCopyJob.perform_later( concern_id )
      end
      Rails.logger.debug "#{@globus_log_prefix} restart all complete"
    end
  end

  protected

  def globus_job_complete_file
    target_file_name_env(@@globus_prep_dir, 'restarted', target_base_name( @globus_concern_id ) )
  end

  def globus_job_complete?
    file = globus_job_complete_file
    Rails.logger.debug "#{@globus_log_prefix} globus job complete file #{file}"
    return false unless File.exists? file
    last_complete_time = File.birthtime file
    token_time = ::GlobusJob.token_time
    Rails.logger.debug "#{@globus_log_prefix} token_time:#{token_time} <= last_complete_time:#{last_complete_time}"
    Rails.logger.debug "#{@globus_log_prefix} token_time.class:#{token_time.class} <= last_complete_time.class:#{last_complete_time.class}"
    token_time <= last_complete_time
  end

end