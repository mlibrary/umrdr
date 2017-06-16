# Generated via
#  `rails generate curation_concerns:work GenericWork`
module Hyrax
  class GenericWorkForm < Umrdr::Forms::WorkForm
    self.model_class = ::GenericWork

    include HydraEditor::Form::Permissions
    self.terms += [:resource_type, :date_coverage]
    self.required_fields = [ :title, :creator, :methodology, :description, :rights, :subject, :authoremail ]

    def rendered_terms
      [ :title, :creator, :authoremail, :methodology, :description, :date_coverage, :rights, :subject, :fundedby, :grantnumber, :keyword, :language, :resource_type, :isReferencedBy, :on_behalf_of, :visibility ]
    end

  end
end
