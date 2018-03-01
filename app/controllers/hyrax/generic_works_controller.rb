require 'edtf'
include EmailHelper

class Hyrax::GenericWorksController < ApplicationController
  # Adds Sufia behaviors to the controller.
  #include Sufia::WorksControllerBehavior
  include Hyrax::WorksControllerBehavior

  # Adds Sufia behaviors to the controller.
  #Override Sufia behavior to change the after_create message
  include Umrdr::WorksControllerBehavior

  before_action :check_recent_uploads, only: [:show]
  before_action :assign_date_coverage, only: [:create, :update]
  before_action :assign_visibility, only: [:create, :update]
  after_action  :notify_rds, only: [:create]
  after_action  :box_work_created, only: [:create]
  after_action  :prov_work_created, only: [:create]
  after_action  :prov_work_updated, only: [:update]
  after_action  :notify_rds_on_update_to_public, only: [:update]
  protect_from_forgery with: :null_session, only: [:download]
  protect_from_forgery with: :null_session, only: [:globus_download]
  protect_from_forgery with: :null_session, only: [:globus_add_email]
  protect_from_forgery with: :null_session, only: [:globus_download_add_email]
  protect_from_forgery with: :null_session, only: [:globus_download_notify_me]

  self.curation_concern_type = GenericWork

  attr_accessor :user_email_one, :user_email_two

  ## box integration

  def box_create_dir
    BoxHelper.create_box_dir curation_concern.id
  end

  def box_link
    BoxHelper.box_link curation_concern.id
  end

  def box_work_created
    box_create_dir
  end

  ## Changes in visibility

  def assign_visibility
    if set_to_draft?
      mark_as_set_to_private!
    else
      mark_as_set_to_public!
    end
  end

  def set_to_draft?
    params["isDraft"] == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
  end

  def mark_as_set_to_private!
    params["generic_work"]["visibility"] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
  end

  def mark_as_set_to_public!
    params["generic_work"]["visibility"] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    if action_name == 'update' and params[:id]
      @visibility_changed_to_public = GenericWork.find(params[:id]).private?
    end
  end

  ## Send email

  def notify_rds
    email_rds( action: 'deposit', description: "deposited by #{curation_concern.depositor}", log_provenance: false )
  end

  def notify_rds_on_update_to_public
    return unless @visibility_changed_to_public
    description = "previously deposited by #{curation_concern.depositor}, was updated to #{curation_concern.visibility} access"
    email_rds( action: 'update', description: description, log_provenance: true )
  end

  def prov_work_created
    provenance_log( action: 'created' )
  end

  def prov_work_updated
    provenance_log( action: 'updated', modified: "on: #{curation_concern.date_modified}" )
  end

  # Begin processes to mint hdl and doi for the work
  def identifiers
    mint_doi
    respond_to do |wants|
      wants.html { redirect_to [main_app, curation_concern] }
      wants.json { render :show, status: :ok, location: polymorphic_path([main_app, curation_concern]) }
    end
  end

  def tombstone
    #Make it so work does not show up in search result for anyone, not even admins.
    curation_concern.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    curation_concern.depositor = 'TOMBSTONE-' +   curation_concern.depositor

    #I tried this but it did not work.  And gets complicated.
    #curation_concern.state = Vocab::FedoraResourceStatus.inactive

    for i in 0 ... curation_concern.file_sets.size
      curation_concern.file_sets[i].visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    end

    curation_concern.tombstone = [params[:tombstone]]
    curation_concern.save

    redirect_to dashboard_works_path, notice: "Tombstoned: \"#{curation_concern.title.first}\" for this reason: #{curation_concern.tombstone.first}"
  end

  def confirm
    render 'confirm_work' 
  end

  ## download_zip

  def download
    require 'zip'
    require 'tempfile'

    tmp_dir = ENV['TMPDIR'] || "/tmp"
    tmp_dir = Pathname tmp_dir
    #Rails.logger.debug "Download Zip begin tmp_dir #{tmp_dir}"
    target_dir = target_dir_name_id( tmp_dir, curation_concern.id )
    #Rails.logger.debug "Download Zip begin copy to folder #{target_dir}"
    Dir.mkdir(target_dir) unless Dir.exist?( target_dir )
    target_zipfile = target_dir_name_id( target_dir, curation_concern.id, ".zip" )
    #Rails.logger.debug "Download Zip begin copy to target_zipfile #{target_zipfile}"
    File.delete target_zipfile if File.exist? target_zipfile
    # clean the zip directory if necessary, since the zip structure is currently flat, only
    # have to clean files in the target folder
    files = Dir.glob( "#{target_dir.join '*'}")
    files.each do |file|
      File.delete file if File.exist? file
    end
    Rails.logger.debug "Download Zip begin copy to folder #{target_dir}"
    Zip::File.open(target_zipfile.to_s, Zip::File::CREATE ) do |zipfile|
      metadata_filename = MetadataHelper.report_generic_work( curation_concern, dir: target_dir )
      zipfile.add( metadata_filename.basename, metadata_filename )
      copy_file_sets_to( target_dir, log_prefix: "Zip: " ) do |target_file_name, target_file|
        zipfile.add( target_file_name, target_file )
      end
    end
    Rails.logger.debug "Download Zip copy complete to folder #{target_dir}"
    send_file target_zipfile.to_s
  end

  ## globus operations

  def globus_add_email
    if user_signed_in?
      user_email = EmailHelper.user_email_from( current_user )
      globus_copy_job( user_email: user_email, delay_per_file_seconds: 0 )
      flash_and_go_back globus_files_prepping_msg( user_email: user_email )
    elsif params[:user_email_one].present? || params[:user_email_two].present?
      user_email_one = params[:user_email_one].present? ? params[:user_email_one].strip : ''
      user_email_two = params[:user_email_two].present? ? params[:user_email_two].strip : ''
      if user_email_one === user_email_two
        globus_copy_job( user_email: user_email_one, delay_per_file_seconds: 0 )
        flash_and_redirect_to_main_cc globus_files_prepping_msg( user_email: user_email_one )
      else
        flash.now[:error] = emails_did_not_match_msg( user_email_one, user_email_two )
        render 'globus_download_add_email_form'
      end
    else
      flash_and_redirect_to_main_cc globus_status_msg
    end
  end

  def globus_copy_job( user_email: nil,
                       delay_per_file_seconds: Umrdr::Application.config.globus_debug_delay_per_file_copy_job_seconds )
    ::GlobusCopyJob.perform_later( curation_concern.id,
                                   user_email: user_email,
                                   delay_per_file_seconds: delay_per_file_seconds )
    if 0 < Umrdr::Application.config.globus_after_copy_job_ui_delay_seconds
      sleep Umrdr::Application.config.globus_after_copy_job_ui_delay_seconds
    end
  end

  def globus_download
    if globus_complete?
      flash_and_redirect_to_main_cc globus_files_available_here
    else
      user_email = EmailHelper.user_email_from( current_user, user_signed_in: user_signed_in? )
      msg = nil
      if globus_prepping?
        msg = globus_files_prepping_msg( user_email: user_email )
      else
        msg = globus_file_prep_started_msg( user_email: user_email )
      end
      if user_signed_in?
        globus_copy_job( user_email: user_email )
        flash_and_redirect_to_main_cc msg
      else
        render 'globus_download_notify_me_form'
      end
    end
  end

  def globus_download_add_email
    if user_signed_in?
      globus_add_email
    else
      render 'globus_download_add_email_form'
    end
  end

  def globus_download_notify_me
    if user_signed_in?
      user_email = EmailHelper.user_email_from( current_user )
      globus_copy_job( user_email: user_email )
      flash_and_go_back globus_file_prep_started_msg( user_email: user_email )
    elsif params[:user_email_one].present? || params[:user_email_two].present?
      user_email_one = params[:user_email_one].present? ? params[:user_email_one].strip : ''
      user_email_two = params[:user_email_two].present? ? params[:user_email_two].strip : ''
      if user_email_one === user_email_two
        globus_copy_job( user_email: user_email_one )
        flash_and_redirect_to_main_cc globus_file_prep_started_msg( user_email: user_email_one )
      else
        #flash_and_go_back emails_did_not_match_msg( user_email_one, user_email_two )
        flash.now[:error] = emails_did_not_match_msg( user_email_one, user_email_two )
        render 'globus_download_notify_me_form'
      end
    else
      globus_copy_job( user_email: nil )
      flash_and_redirect_to_main_cc globus_file_prep_started_msg
    end
  end

  # Create EDTF::Interval from form parameters
  # Replace the date coverage parameter prior with serialization of EDTF::Interval
  def assign_date_coverage
    cov_interval = Umrdr::DateCoverageService.params_to_interval params
    params['generic_work']['date_coverage'] = cov_interval ? [cov_interval.edtf] : []
  end

  def check_recent_uploads
    if params[:uploads_since]
      begin
        @recent_uploads = [];
        uploads_since = Time.at(params[:uploads_since].to_i / 1000.0)
        presenter.file_set_presenters.reverse_each do |file_set|
          date_uploaded = get_date_uploaded_from_solr(file_set)
          if date_uploaded.nil? or date_uploaded < uploads_since
            break
          end
          @recent_uploads.unshift file_set
        end
      rescue Exception => e
        Rails.logger.info "Something happened in check_recent_uploads: #{params[:uploads_since]} : #{e.message}"
      end
    end
  end

  # TODO move this to an actor after sufia 7.0 dependency.

  def mint_doi
    # Do not mint doi if
    #   one already exists
    #   work file_set count is 0.
    if curation_concern.doi
      flash[:notice] = "A DOI already exists or is being minted."
      return
    elsif curation_concern.file_sets.count < 1
      flash[:notice] = "DOI cannot be minted for a work without files."
      return
    end

    # Assign doi as "pending" in the meantime
    curation_concern.doi = GenericWork::PENDING

    # save (and re-index)
    curation_concern.save

    # Kick off job to get a doi
    msg = "DOI process kicked off for work id: #{curation_concern.id}"
    PROV_LOGGER.info (msg)
    ::DoiMintingJob.perform_later(curation_concern.id)
  end

  def copy_file_sets_to( target_dir \
                       , log_prefix: "" \
                       , do_copy_predicate: lambda { |target_file_name, target_file| true } \
                       , quiet: false \
                       , &block \
                       )
    file_sets = curation_concern.file_sets
    Hyrax::GenericWorksController.copy_file_sets( target_dir \
                                                , file_sets \
                                                , log_prefix: log_prefix \
                                                , do_copy_predicate: do_copy_predicate \
                                                , quiet: quiet \
                                                , &block \
                                                )
  end

  def self.copy_file_sets( target_dir \
                         , file_sets \
                         , log_prefix: "copy_file_sets" \
                         , do_copy_predicate: lambda { |target_file_name, target_file| true } \
                         , quiet: false \
                         , &on_copy_block \
                         )
    Rails.logger.debug "#{log_prefix} Starting copy to #{target_dir}" unless quiet
    files_extracted = Hash.new
    total_bytes = 0
    file_sets.each do |file_set|
      file = file_set.files[0]
      file_set.files.each do | f |
        file = f unless f.original_name == ''
      end
      if file.nil?
        Rails.logger.warning "#{log_prefix} file_set.id #{file_set.id} files[0] is nil"
      else
        target_file_name = file_set.label
        # fix possible issues with target file name
        target_file_name = '_nil_' if target_file_name.nil?
        target_file_name = '_empty_' if target_file_name.empty?
        if files_extracted.has_key? target_file_name
          dup_count = 1
          base_ext = File.extname target_file_name
          base_target_file_name = File.basename target_file_name, base_ext
          target_file_name = base_target_file_name + "_" + dup_count.to_s.rjust( 3, '0' ) + base_ext
          while files_extracted.has_key? target_file_name
            dup_count += 1
            target_file_name = base_target_file_name + "_" + dup_count.to_s.rjust( 3, '0' ) + base_ext
          end
        end
        files_extracted.store( target_file_name, true )
        target_file = target_dir.join target_file_name
        if do_copy_predicate.call( target_file_name, target_file )
          source_uri = file.uri.value
          #Rails.logger.debug "#{log_prefix} #{source_uri} exists? #{File.exist?( source_uri )}" unless quiet
          Rails.logger.debug "#{log_prefix} copy #{target_file} << #{source_uri}" unless quiet
          bytes_copied = open(source_uri) { |io| IO.copy_stream(io, target_file) }
          total_bytes += bytes_copied
          copied = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert( bytes_copied, precision: 3 )
          Rails.logger.debug "#{log_prefix} copied #{copied} to #{target_file}" unless quiet
          on_copy_block.call( target_file_name, target_file ) if on_copy_block
        else
          Rails.logger.debug "#{log_prefix} skipped copy of #{target_file}" unless quiet
        end
      end
    end
    total_copied = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert( total_bytes, precision: 3 )
    Rails.logger.debug "#{log_prefix} Finished copy to #{target_dir}; total #{total_copied} in #{files_extracted.size} files" unless quiet
    total_bytes
  end

  def globus_complete?
    ::GlobusJob.copy_complete? curation_concern.id
  end

  def globus_prepping?
    ::GlobusJob.files_prepping? curation_concern.id
  end

  def globus_url
    ::GlobusJob.external_url curation_concern.id
  end

  protected

  def emails_did_not_match_msg( user_email_one, user_email_two )
    "Emails did not match" # + ": '#{user_email_one}' != '#{user_email_two}'"
  end

  def email_rds_and_user( action: 'create', description: '', log_provenance: false )
    email_to = EmailHelper.user_email_from( current_user )
    email_from = EmailHelper.notification_email # will be nil on developer's machine
    email_it( action: action,
              description: description,
              log_provenance: log_provenance,
              email_to: email_to,
              email_from: email_from )
  end

  def email_rds( action: 'deposit', description: '', log_provenance: false )
    email_to = EmailHelper.notification_email # will be nil on developer's machine
    email_it( action: action, description: description, log_provenance: log_provenance, email_to: email_to )
  end

  def email_it( action: 'deposit', description: '', log_provenance: false, email_to: '', email_from: nil )
    location = MsgHelper.work_location( curation_concern )
    title    = MsgHelper.title( curation_concern )
    creator  = MsgHelper.creator( curation_concern )
    msg      = "#{title} (#{location}) by + #{creator} with #{curation_concern.visibility} access was #{description}"
    Rails.logger.debug "email_it: action=#{action} email_to=#{email_to} email_from=#{email_from} msg='#{msg}'"
    if log_provenance
      PROV_LOGGER.info( msg )
    end
    email = nil
    case action
      when 'deposit'
        email = WorkMailer.deposit_work( to: email_to, body: msg )
      when 'delete'
        email = WorkMailer.delete_work( to: email_to, body: msg )
      when 'create'
        email = WorkMailer.create_work( to: email_to, body: msg )
      when 'publish'
        email = WorkMailer.publish_work( to: email_to, body: msg )
      when 'update'
        email = WorkMailer.update_work( to: email_to, body: msg )
      else
        Rails.logger.error "email_it unknown action #{action}"
    end
    email.deliver_now unless email.nil? || email_to.nil?
    unless email_from.nil?
      email = nil
      case action
        when 'deposit'
          email = WorkMailer.deposit_work( to: email_to, from: email_from, body: msg )
        when 'delete'
          email = WorkMailer.delete_work( to: email_to, from: email_from, body: msg )
        when 'create'
          email = WorkMailer.create_work( to: email_to, from: email_from, body: msg )
        when 'publish'
          email = WorkMailer.publish_work( to: email_to, from: email_from, body: msg )
        when 'update'
          email = WorkMailer.update_work( to: email_to, from: email_from, body: msg )
        else
          Rails.logger.error "email_it unknown action #{action}"
      end
      email.deliver_now unless email.nil? || email_to.nil?
    end
  end

  def flash_and_go_back( msg )
    Rails.logger.debug msg
    redirect_to :back, notice: msg
  end

  def flash_error_and_go_back( msg )
    Rails.logger.debug msg
    redirect_to :back, error: msg
  end

  def flash_and_redirect_to_main_cc( msg )
    Rails.logger.debug msg
    redirect_to [main_app, curation_concern], notice: msg
  end

  def globus_file_prep_started_msg( user_email: nil )
    msg = "Files have started copying to Globus. #{globus_files_when_available( user_email: user_email )}"
  end

  def globus_files_prepping_msg( user_email: nil )
    "Files are currently being copied to Globus. #{globus_files_when_available( user_email: user_email )}"
  end

  def globus_files_when_available( user_email: nil )
    if user_email.nil?
      "Please check back later."
    else
      "#{user_email} will be sent an email when the files are available for download via Globus."
    end
  end

  def globus_files_available_here
    "Files are available for download using Globus here: #{globus_url}"
  end

  def globus_status_msg( user_email: nil )
    msg = nil
    if globus_complete?
      msg = globus_files_available_here
    elsif globus_prepping?
      msg = globus_files_prepping_msg( user_email: user_email )
    else
      msg = globus_file_prep_started_msg( user_email: user_email )
    end
    msg
  end

  def provenance_log( prefix: '', action: '', modified: '' )
    location    = MsgHelper.work_location( curation_concern )
    title       = MsgHelper.title( curation_concern )
    creator     = MsgHelper.creator( curation_concern )
    description = MsgHelper.description( curation_concern )
    publisher   = MsgHelper.publisher( curation_concern )
    subject     = MsgHelper.subject( curation_concern )
    msg = "WORK #{action.capitalize}: (#{location}) by + #{creator} with #{curation_concern.visibility} access was #{action}" +
        " title: #{title} " + "#{modified}"
    ", rights: #{curation_concern.rights[0]}" +
        ", methodology: #{curation_concern.methodology}" +
        ", publisher: #{publisher}" +
        ", subject: #{subject}" +
        ", description: #{description}" +
        ", admin set id: #{curation_concern.admin_set_id}"
    PROV_LOGGER.info (msg)
  end

  def show_presenter
    Umrdr::WorkShowPresenter
  end

  private

  def get_date_uploaded_from_solr(file_set)
    field = file_set.solr_document[Solrizer.solr_name('date_uploaded', :stored_sortable, type: :date)]
    return unless field.present?
    begin
      Time.parse(field)
    rescue
      Rails.logger.info "Unable to parse date: #{field.first.inspect} for #{self['id']}"
    end
  end

  def target_dir_name_id( dir, id, ext = '' )
    dir.join "#{Umrdr::Application.config.base_file_name}#{id}#{ext}"
  end

end
