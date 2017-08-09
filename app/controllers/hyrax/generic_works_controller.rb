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
    PROV_LOGGER.info (msg)
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
    return if @recent_globus_dir.nil?
    location   = main_app.hyrax_generic_work_url(curation_concern.id)
    depositor  = curation_concern.depositor
    title      = curation_concern.title.join("','")
    creator    = curation_concern.creator.join("','")
    work_info = "work " + title + " (" + location + ") by " + creator +
                 ", previously deposited by " + depositor + "."
                 
    msg        = "Globus files are available at: #{@recent_globus_dir} for " + work_info        
    email      = WorkMailer.globus_push_work(Rails.configuration.user_email, msg)
    email.deliver_now
    # @recent_globus_dir = nil
  end

  # Begin processes to mint hdl and doi for the work
  def identifiers
    mint_doi
    respond_to do |wants|
      wants.html { redirect_to [main_app, curation_concern] }
      wants.json { render :show, status: :ok, location: polymorphic_path([main_app, curation_concern]) }
    end
  end

  def download 
    require 'zip' 
    require 'tempfile'

    tmp_dir = ENV['TMPDIR'] || "/tmp"
    folder = tmp_dir + "/DeepBlueData_" + curation_concern.id
    zipfile_name = folder + "/DeepBlueData_" + curation_concern.id + ".zip"
    FileUtils.rm_rf(folder) if File.exists?(folder)
    Dir.mkdir(folder) unless File.exists?(folder)
    FileUtils.rm_rf(Dir.glob(folder + '/*')) 

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      curation_concern.file_sets.each do |file_set|   
        file = file_set.files[0]
        filename = file_set.label

        url = file.uri.value
        output = folder + "/" + filename

        open(url) do |io|
          IO.copy_stream(io, output)
        end
        zipfile.add(filename, output)
      end
    end
    send_file zipfile_name 
  end  

  # For local testing set globus_dir = "."
  def globus 
    require 'tempfile'

    # hard coding the nectar umrdr-data directory to
    # use unless ENV['GLOBUSDIR'] is set
    globus_dir = ENV['GLOBUSDIR'] || "/hydra-dev/umrdr-data/globus"
    # globus_dir = "."
    folder = globus_dir + "/DeepBlueData_" + curation_concern.id
    
    FileUtils.rm_rf(folder) if File.exists?(folder)
    Dir.mkdir(folder) unless File.exists?(folder)
    FileUtils.rm_rf(Dir.glob(folder + '/*')) 
    
    curation_concern.file_sets.each do |file_set|   
      file = file_set.files[0]
      filename = file_set.label

      url = file.uri.value
      output = folder + "/" + filename
  
      open(url) do |io|
        IO.copy_stream(io, output)
      end
    end
    @recent_globus_dir = folder
    flash[:notice] = "Globus data is ready in directory: #{@recent_globus_dir}"
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

end
