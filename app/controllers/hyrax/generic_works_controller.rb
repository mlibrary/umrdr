require 'edtf'

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
  after_action  :notify_rdr, only: [:create]
  after_action  :prov_work_created, only: [:create]
  after_action  :prov_work_updated, only: [:update]
  after_action  :notify_rdr_on_update_to_public, only: [:update]
  after_action  :notify_user_on_globus, only: [:globus]
  protect_from_forgery with: :null_session, only: [:download]
  protect_from_forgery with: :null_session, only: [:globus]

  self.curation_concern_type = GenericWork

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

  def notify_rdr
    location   = main_app.hyrax_generic_work_url(curation_concern.id)
    depositor  = curation_concern.depositor
    title      = curation_concern.title.join("','")
    creator    = curation_concern.creator.join("','")
    visibility = curation_concern.visibility
    msg        = title + " (" + location + ") by " + creator +
        ", with " + visibility +
        " access was deposited by " + depositor
    email      = WorkMailer.deposit_work(Rails.configuration.notification_email, msg)
    email.deliver_now
  end

  def notify_rdr_on_update_to_public
    return unless @visibility_changed_to_public
    location   = main_app.hyrax_generic_work_url(curation_concern.id)
    depositor  = curation_concern.depositor
    title      = curation_concern.title.join("','")
    creator    = curation_concern.creator.join("','")
    visibility = curation_concern.visibility
    msg        = title + " (" + location + ") by " + creator +
        ", previously deposited by " + depositor +
        ", was updated to " + visibility + " access"
    PROV_LOGGER.info (msg)
    email      = WorkMailer.publish_work(Rails.configuration.notification_email, msg)
    email.deliver_now
  end

  def notify_user_on_globus
    # return if @recent_globus_dir.nil?
    # location   = main_app.hyrax_generic_work_url(curation_concern.id)
    # depositor  = curation_concern.depositor
    # title      = curation_concern.title.join("','")
    # creator    = curation_concern.creator.join("','")
    # work_info = "work " + title + " (" + location + ") by " + creator +
    #              ", previously deposited by " + depositor + "."
    #
    # msg        = "Globus files are available at: #{@recent_globus_dir} for " + work_info
    # PROV_LOGGER.info (msg)
    # email      = WorkMailer.globus_push_work(Rails.configuration.user_email, msg)
    # email.deliver_now
    # # @recent_globus_dir = nil
  end

  def prov_work_created
    location      = main_app.hyrax_generic_work_url(curation_concern.id)
    depositor     = curation_concern.depositor
    methodology   = curation_concern.methodology
    visibility = curation_concern.visibility
    rights = curation_concern.rights
    title         = curation_concern.title.join("','")
    creator       = curation_concern.creator.join("','")
    description   = curation_concern.description.join("','")
    publisher     = curation_concern.publisher.join("','")
    subject       = curation_concern.subject.join("','")
    admin_set_id  = curation_concern.admin_set_id

    msg        = "WORK CREATED:" + " (" + location + ") by " + creator +
        ", with " + visibility +
        " access was created with title: " + title +
        ", rights: " + rights[0] +
        ", methodology: " + methodology +
        ", publisher: " + publisher +
        ", subject: " + subject +
        ", description: " + description +
        ", admin set id: " + admin_set_id
    PROV_LOGGER.info (msg)
  end

  def prov_work_updated
    location      = main_app.hyrax_generic_work_url(curation_concern.id)
    depositor     = curation_concern.depositor
    methodology   = curation_concern.methodology
    visibility = curation_concern.visibility
    date_modified = curation_concern.date_modified
    rights = curation_concern.rights
    title         = curation_concern.title.join("','")
    creator       = curation_concern.creator.join("','")
    description   = curation_concern.description.join("','")
    publisher     = curation_concern.publisher.join("','")
    subject       = curation_concern.subject.join("','")
    admin_set_id  = curation_concern.admin_set_id

    msg        = "WORK UPDATED:" + " (" + location + ") by " + creator +
        ", with " + visibility +
        " access was updated with title: " + title +
        ", on: " + date_modified.to_s +
        ", rights: " + rights[0] +
        ", methodology: " + methodology +
        ", publisher: " + publisher +
        ", subject: " + subject +
        ", description: " + description +
        ", admin set id: " + admin_set_id
    PROV_LOGGER.info (msg)
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

  def download
    require 'zip'
    require 'tempfile'

    tmp_dir = ENV['TMPDIR'] || "/tmp"
    tmp_dir = Pathname tmp_dir
    #Rails.logger.debug "Download Zip begin tmp_dir #{tmp_dir}"
    target_dir = target_dir_name_id( tmp_dir, curation_concern.id )
    #Rails.logger.debug "Download Zip begin copy to folder #{target_dir}"
    Dir.mkdir(target_dir) unless Dir.exists?( target_dir )
    target_zipfile = target_dir_name_id( target_dir, curation_concern.id, ".zip" )
    #Rails.logger.debug "Download Zip begin copy to target_zipfile #{target_zipfile}"
    File.delete target_zipfile if File.exists? target_zipfile
    # clean the zip directory if necessary, since the zip structure is currently flat, only
    # have to clean files in the target folder
    files = Dir.glob( "#{target_dir.join '*'}")
    files.each do |file|
      File.delete file if File.exists? file
    end
    Rails.logger.debug "Download Zip begin copy to folder #{target_dir}"
    Zip::File.open(target_zipfile.to_s, Zip::File::CREATE ) do |zipfile|
      copy_file_sets_to( target_dir, log_prefix: "Zip: " ) do |target_file_name, target_file|
        zipfile.add( target_file_name, target_file )
      end
    end
    Rails.logger.debug "Download Zip copy complete to folder #{target_dir}"
    send_file target_zipfile.to_s
  end

  def globus
    concern_id = curation_concern.id
    msg = nil
    if globus_complete?
      msg = "Globus files are available for download here: #{globus_url}"
    else
      if globus_prepping?
        msg = "Files are being copied to globus and are not yet available. Please try again later."
      else
        msg = "Files are being copied to globus. Please check back later."
      end
      ::GlobusCopyJob.perform_later( concern_id ) #, generate_error: false )
    end
    Rails.logger.debug msg
    flash.now[:notice] = msg
    redirect_to :back
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
                       , &block \
                       )
    file_sets = curation_concern.file_sets
    Hyrax::GenericWorksController.copy_file_sets( target_dir \
                                                , file_sets \
                                                , log_prefix: log_prefix \
                                                , do_copy_predicate: do_copy_predicate \
                                                , &block \
                                                )
  end

  def self.copy_file_sets( target_dir \
                         , file_sets \
                         , log_prefix: "copy_file_sets" \
                         , do_copy_predicate: lambda { |target_file_name, target_file| true } \
                         , &on_copy_block \
                         )
    Rails.logger.debug "#{log_prefix} Starting copy to #{target_dir}"
    files_extracted = Hash.new
    total_bytes = 0
    file_sets.each do |file_set|
      file = file_set.files[0]
      target_file_name = file_set.label
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
        Rails.logger.debug "#{log_prefix} #{source_uri} exists? #{File.exists?( source_uri )}"
        Rails.logger.debug "#{log_prefix} copy #{target_file} << #{source_uri}"
        bytes_copied = open(source_uri) { |io| IO.copy_stream(io, target_file) }
        total_bytes += bytes_copied
        copied = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert( bytes_copied, precision: 3 )
        Rails.logger.debug "#{log_prefix} copied #{copied} to #{target_file}"
        on_copy_block.call( target_file_name, target_file ) if on_copy_block
      else
        Rails.logger.debug "#{log_prefix} skipped copy of #{target_file}"
      end
    end
    total_copied = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert( total_bytes, precision: 3 )
    Rails.logger.debug "#{log_prefix} Finished copy to #{target_dir}; total #{total_copied} in #{files_extracted.size} files"
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
