include EmailHelper

class GlobusCopyJob < GlobusJob
  queue_as :globus_copy

  # @param [String] concern_id
  # @param [String, "Globus: " ] log_prefix
  # @param [boolean, false] generate_error
  # @param [integer, 0 ] delay_per_file_seconds
  # @param [String, nil ] user_email
  def perform( concern_id, log_prefix: "Globus: ", generate_error: false, delay_per_file_seconds: 0, user_email: nil )
    globus_job_perform( concern_id: concern_id, email: user_email, log_prefix: "#{log_prefix}globus_copy_job" ) do
      Rails.logger.debug "#{@globus_log_prefix} begin copy" unless @globus_job_quiet
      @target_download_dir = target_download_dir @globus_concern_id
      prefix = "#{Rails.env}_"
      @target_prep_dir = target_prep_dir( @globus_concern_id, prefix: prefix, mkdir: true )
      @target_prep_dir_tmp = target_prep_tmp_dir(@globus_concern_id, prefix: prefix, mkdir: true )
      curation_concern = ActiveFedora::Base.find @globus_concern_id
      file_sets = curation_concern.file_sets
      do_copy_predicate = lambda { |target_file_name, target_file| globus_do_copy?( target_file_name ) }
      Hyrax::GenericWorksController.copy_file_sets( @target_prep_dir_tmp \
                                                  , file_sets \
                                                  , log_prefix: @globus_log_prefix \
                                                  , do_copy_predicate: do_copy_predicate \
                                                  ) do |target_file_name, target_file|
        if 0 < delay_per_file_seconds
          sleep delay_per_file_seconds
        end
        move_destination = GlobusJob.target_file_name( @target_prep_dir, target_file_name )
        Rails.logger.debug "#{@globus_log_prefix} mv #{target_file} to #{move_destination}" unless @globus_job_quiet
        FileUtils.move( target_file, move_destination )
        if generate_error
          @globus_lock_file = nil
          raise StandardError, "generated error"
        end
      end
      Rails.logger.debug "#{@globus_log_prefix} mv #{@target_prep_dir} to #{@target_download_dir}" unless @globus_job_quiet
      FileUtils.move( @target_prep_dir, @target_download_dir )
      FileUtils.rmdir @target_prep_dir_tmp
      Rails.logger.debug "#{@globus_log_prefix} copy complete" unless @globus_job_quiet
      begin
        globus_copy_job_email_add( user_email )
        @email_lines = globus_copy_job_complete_lines( curation_concern )
        globus_copy_job_email_all
        globus_copy_job_email_reset
        if Umrdr::Application.config.globus_log_provenance_copy_job_complete
          globus_copy_job_log_provenance
        end
      rescue Exception => e
        msg = "#{@globus_log_prefix} #{e.class}: #{e.message} at #{e.backtrace[0]}"
        Rails.logger.error msg
      end
    end
  end

  def globus_copy_job_email_add( email = nil )
    email_file = globus_copy_job_email_file
    Rails.logger.debug "#{@globus_log_prefix} globus_copy_job_email_add #{email} to #{email_file}" unless @globus_job_quiet
    open( email_file, 'a' ) do |file|
      globus_file_lock( file ) do |out|
        if email.nil?
          out << ''
        else
          out << "#{email}\n"
        end
      end
    end
  end

  protected

  @email_lines

  def globus_copy_job_complete_lines( curration_concern )
    lines = []
    lines << "Globus download is now available."
    lines << "Work: #{MsgHelper.title(curration_concern)}"
    lines << "At: #{MsgHelper.work_location(curration_concern)}"
    lines << "By: #{MsgHelper.creator(curration_concern)}"
    lines << "Deposited by: #{curration_concern.depositor}"
    lines << "Globus link: #{MsgHelper.globus_link(curration_concern)}"
    return lines
  rescue Exception => e
    msg = "#{@globus_log_prefix} #{e.class}: #{e.message} at #{e.backtrace[0]}"
    Rails.logger.error msg
  end

  def globus_copy_job_email_user( email: nil, lines: [] )
    return if email.nil?
    Rails.logger.debug "#{@globus_log_prefix} globus_copy_job_email_user: work id: #{@globus_concern_id} email: #{email}" unless @globus_job_quiet
    msg = lines.join( "\n" )
    email = WorkMailer.globus_job_complete( email, msg )
    email.deliver_now
  end

  def globus_copy_job_email_all( emails: nil, lines: nil )
    emails = globus_copy_job_emails if emails.nil?
    Rails.logger.debug "#{@globus_log_prefix} globus_copy_job_email_all emails=#{emails}" unless @globus_job_quiet
    return if 0 == emails.count
    lines = @email_lines if lines.nil?
    Rails.logger.debug "#{@globus_log_prefix} globus_copy_job_email_all lines=#{lines}" unless @globus_job_quiet
    emails.each { |email| globus_copy_job_email_user( email: email, lines: lines ) }
  rescue Exception => e
    msg = "#{@globus_log_prefix} #{e.class}: #{e.message} at #{e.backtrace[0]}"
    Rails.logger.error msg
  end

  def globus_copy_job_email_file
    rv = GlobusJob.target_file_name_env( @@globus_prep_dir, 'copy_job_emails', GlobusJob.target_base_name( @globus_concern_id ) )
    return rv
  end

  def globus_copy_job_email_reset
    email_file = globus_copy_job_email_file
    Rails.logger.debug "#{@globus_log_prefix} globus_copy_job_email_reset exists? #{email_file}" unless @globus_job_quiet
    if File.exist? email_file
      Rails.logger.debug "#{@globus_log_prefix} globus_copy_job_email_reset delete #{email_file}" unless @globus_job_quiet
      File.delete email_file
    end
  end

  def globus_copy_job_emails
    email_addresses = Hash.new
    email_file = globus_copy_job_email_file
    Rails.logger.debug "#{@globus_log_prefix} globus_copy_job_emails email_file=#{email_file}" unless @globus_job_quiet
    if File.exist? email_file
      # read the file, one email address per line
      open( email_file, 'r' ) do |file|
        globus_file_lock( file, mode: File::LOCK_SH ) do |fin|
          until fin.eof?
            line = fin.readline
            line = line.chomp!
            Rails.logger.debug "#{@globus_log_prefix} globus_copy_job_emails line=#{line}" unless @globus_job_quiet
            email_addresses[line] = true unless line.empty?
          end
        end
      end
    end
    return email_addresses.keys
  end

  def globus_copy_job_log_provenance
    msg = @email_lines.join( ', ' )
    PROV_LOGGER.info( msg )
  end

  def globus_do_copy?( target_file_name )
    prep_file_name = GlobusJob.target_file_name( @target_prep_dir, target_file_name )
    do_copy = true
    if File.exist? prep_file_name
      Rails.logger.debug "#{@globus_log_prefix} skipping copy because #{prep_file_name} already exists" unless @globus_job_quiet
      do_copy = false
    end
    do_copy
  end

  def globus_job_complete?
    globus_copy_job_complete? @globus_concern_id
  end

  def globus_job_complete_file
    globus_ready_file
  end

  def globus_job_perform_in_progress( email: nil )
    globus_copy_job_email_add( email )
    super.globus_job_perform_in_progress( email: email )
  end

  # def globus_notify_user( curation_concern, user_email: nil ) # TODO: turn user_email into list
  #   Rails.logger.debug "globus_notify_user: work id: #{curation_concern.id} user_email: #{user_email}" unless @globus_job_quiet
  #   concern_id = curation_concern.id
  #   location  = Rails.application.routes.url_helpers.hyrax_generic_work_url( id: concern_id )
  #   depositor = curation_concern.depositor
  #   title     = curation_concern.title.join("','")
  #   creator   = curation_concern.creator.join("','")
  #   work_info = "work #{title} (#{location}) by #{creator}, deposited by #{depositor}."
  #   globus_url = ::GlobusJob.external_url concern_id
  #   msg = "Globus files are available at: #{globus_url} for #{work_info}"
  #   PROV_LOGGER.info( msg )
  #   return if user_email.nil?
  #   msg = "\nGlobus files are available at:\n#{globus_url}\nfor #{work_info}\n"
  #   email = WorkMailer.globus_push_work( user_email, user_email, msg )
  #   email.deliver_now
  # rescue Exception => e
  #   msg = "#{@globus_log_prefix} #{e.class}: #{e.message} at #{e.backtrace[0]}"
  #   Rails.logger.error msg
  #   #globus_error msg
  # end

  def globus_ready_file
    GlobusJob.target_file_name_env( @@globus_prep_dir, 'ready', GlobusJob.target_base_name( @globus_concern_id ) )
  end

end