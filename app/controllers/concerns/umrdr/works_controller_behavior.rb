module Umrdr
  module WorksControllerBehavior
    extend ActiveSupport::Concern
    include Sufia::Controller
    include Sufia::WorksControllerBehavior
    include CurationConcerns::CurationConcernController

    
    # override curation concerns, add form fields values
    def build_form
      super
      # Set up the multiple parameters for the date coverage attribute in the form
      cov_date = Date.edtf(@form.date_coverage.first)
      cov_params = Umrdr::DateCoverageService.interval_to_params cov_date
      @form.merge_date_coverage_attributes! cov_params
    end

    def after_create_response
      respond_to do |wants|
        wants.html { redirect_to [main_app, curation_concern] }
        wants.json { render :show, status: :created, location: polymorphic_path([main_app, curation_concern]) }
      end
    end
  end
end
