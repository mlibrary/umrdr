module Umrdr
  module WorksControllerBehavior
    extend ActiveSupport::Concern
    include Sufia::Controller
    include Sufia::WorksControllerBehavior
    include CurationConcerns::CurationConcernController
       
    # override curation concerns, add form fields values
    def build_form
    
      super
    
      date_range = Umrdr::DateFormService.new(@form["date_coverage"].first).parse
      if date_range
      
        @form["date_coverage_1_year"] = date_range[0]
        @form["date_coverage_1_month"] = date_range[1]
        @form["date_coverage_1_day"] = date_range[2]
        @form["date_coverage_2_year"] = date_range[3]
        @form["date_coverage_2_month"] = date_range[4]
        @form["date_coverage_2_day"] = date_range[5] 
     end  
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
