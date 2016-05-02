module Umrdr
  module WorksControllerBehavior
    extend ActiveSupport::Concern
    include Sufia::Controller
    include Sufia::WorksControllerBehavior
    include CurationConcerns::CurationConcernController
       
    # override curation concerns, add form fields values
    def build_form
    
      super
      st = EDTF.parse(@form["date_coverage"])
      if (!st.eql? nil)
        @form["date_coverage_1_day"] = st.day
        @form["date_coverage_1_month"] = st.mon
        @form["date_coverage_1_year"] = st.year    
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
