module Umrdr
  module WorksControllerBehavior
    extend ActiveSupport::Concern
    include Hyrax::Controller
    include Hyrax::WorksControllerBehavior
    
    class_methods do
      def curation_concern_type=(curation_concern_type)
        load_and_authorize_resource class: curation_concern_type, instance_name: :curation_concern, except: [:show, :file_manager, :inspect_work]

        # Load the fedora resource to get the etag.
        # No need to authorize for the file manager, because it does authorization via the presenter.
        load_resource class: curation_concern_type, instance_name: :curation_concern, only: :file_manager

        self._curation_concern_type = curation_concern_type
        # We don't want the breadcrumb action to occur until after the concern has
        # been loaded and authorized
        before_action :save_permissions, only: :update
      end

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
end
