# Generated via
#  `rails generate curation_concerns:work GenericWork`
require 'edtf'
class CurationConcerns::GenericWorksController < ApplicationController
  include CurationConcerns::CurationConcernController
  # Adds Sufia behaviors to the controller.
  #Override Sufia behavior to change the after_create message
  include Umrdr::WorksControllerBehavior

  before_action :check_recent_uploads, only: [:show]
  before_action :check_date_coverage, only: [:create]
  after_action  :notify_rdr, only: [:create]

  set_curation_concern_type GenericWork

  
  def update
    date_coverage_from = Umrdr::DateRangeService.new(params).transform_dt1
    date_coverage_to= Umrdr::DateRangeService.new(params).transform_dt2
    params['generic_work']['date_coverage_from'] = date_coverage_from
    params['generic_work']['date_coverage_to'] = date_coverage_to
    super
  end  

  def notify_rdr
    @msg = main_app.curation_concerns_generic_work_url(curation_concern.id) 
    email = WorkMailer.deposit_work(Sufia.config.notification_email,@msg)
    email.deliver_now
  end


  # Begin processes to mint hdl and doi for the work
  def identifiers
    mint_doi
    respond_to do |wants|
      wants.html { redirect_to [main_app, curation_concern] }
      wants.json { render :show, status: :ok, location: polymorphic_path([main_app, curation_concern]) }
    end
  end
 
  def check_date_coverage
    
    date_coverage_from = Umrdr::DateRangeService.new(params).transform_dt1
    date_coverage_to = Umrdr::DateRangeService.new(params).transform_dt2
    params['generic_work']['date_coverage_from'] = date_coverage_from
    params['generic_work']['date_coverage_to'] = date_coverage_to
    
  end  

  def check_recent_uploads
    if params[:uploads_since]
      begin
        @recent_uploads = [];
        uploads_since = Time.at(params[:uploads_since].to_i / 1000.0)
        presenter.file_presenters.reverse_each do |file_set|
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

    # TODO move this to an actor after sufia 7.0 dependency.

    def mint_doi
      # Check that work doesn't already have a doi.
      return unless curation_concern.doi.nil?

      # Assign doi as "pending" in the meantime
      curation_concern.doi = GenericWork::PENDING

      # save (and re-index)
      curation_concern.save

      # Kick off job to get a doi
      ::DoiMintingJob.perform_later(curation_concern.id)
    end

end
