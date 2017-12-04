include EmailHelper

class GlobusCopyJob < GlobusJob
  queue_as :globus_copy

  # @param [String] concern_id
  # @param [String, "Globus: "] log_prefix
  # @param [boolean, false] generate_error
  def perform( concern_id, log_prefix: "Globus: ", generate_error: false, user_email: nil )
    globus_job_perform( concern_id: concern_id, log_prefix: "#{log_prefix}globus_copy_job" ) do
      Rails.logger.debug "#{@globus_log_prefix} begin copy"
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
        move_destination = target_file_name( @target_prep_dir, target_file_name )
        Rails.logger.debug "#{@globus_log_prefix} mv #{target_file} to #{move_destination}"
        FileUtils.move( target_file, move_destination )
        if generate_error
          @globus_lock_file = nil
          raise StandardError, "generated error"
        end
      end
      Rails.logger.debug "#{@globus_log_prefix} mv #{@target_prep_dir} to #{@target_download_dir}"
      FileUtils.move( @target_prep_dir, @target_download_dir )
      FileUtils.rmdir @target_prep_dir_tmp
      globus_notify_user( curation_concern, user_email: user_email )
      Rails.logger.debug "#{@globus_log_prefix} copy complete"
    end
  end

  protected

  def globus_do_copy?( target_file_name )
    prep_file_name = target_file_name( @target_prep_dir, target_file_name )
    do_copy = true
    if File.exists? prep_file_name
      Rails.logger.debug "#{@globus_log_prefix} skipping copy because #{prep_file_name} already exists"
      do_copy = false
    end
    do_copy
  end

  def globus_job_complete_file
    globus_ready_file
  end

  def globus_job_complete?
    globus_copy_job_complete? @globus_concern_id
  end

  def globus_notify_user( curation_concern, user_email: nil ) # TODO: turn user_email into list
    Rails.logger.debug "globus_notify_user: work id: #{curation_concern.id} user_email: #{user_email}"
    concern_id = curation_concern.id
    location  = Rails.application.routes.url_helpers.hyrax_generic_work_url( id: concern_id )
    depositor = curation_concern.depositor
    title     = curation_concern.title.join("','")
    creator   = curation_concern.creator.join("','")
    work_info = "work #{title} (#{location}) by #{creator}, deposited by #{depositor}."
    globus_url = ::GlobusJob.external_url concern_id
    msg = "Globus files are available at: #{globus_url} for #{work_info}"
    PROV_LOGGER.info( msg )
    return if user_email.nil?
    msg = "\nGlobus files are available at:\n#{globus_url}\nfor #{work_info}\n"
    email = WorkMailer.globus_push_work( user_email, user_email, msg )
    email.deliver_now
  rescue Exception => e
    msg = "#{@globus_log_prefix} #{e.class}: #{e.message} at #{e.backtrace[0]}"
    Rails.logger.error msg
    #globus_error msg
  end

  def globus_ready_file
    target_file_name_env( @@globus_prep_dir, 'ready', target_base_name( @globus_concern_id ) )
  end

end