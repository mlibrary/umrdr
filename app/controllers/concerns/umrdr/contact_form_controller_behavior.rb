module Umrdr
  module ContactFormControllerBehavior
    def new
      @contact_form = ContactForm.new
      if params[:via] == 'doi'
        @contact_form.subject = I18n.t("contact_form.subject.doi_persistence")
        @contact_form.category = Umrdr::Application.config.contact_issue_type_data_management
      end
    end
  end
end
