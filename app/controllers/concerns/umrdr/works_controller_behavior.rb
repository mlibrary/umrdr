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
        wants.html do
          flash[:notice] = "Your files are being processed by #{t('curation_concerns.product_name')} in " \
            "the background. The metadata and access controls you specified are being applied. " 
          redirect_to [main_app, curation_concern]
        end
        wants.json { render :show, status: :created, location: polymorphic_path([main_app, curation_concern]) }
      end
    end
  end
end
