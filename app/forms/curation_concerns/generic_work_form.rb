# Generated via
#  `rails generate curation_concerns:work GenericWork`
module CurationConcerns
  class GenericWorkForm < Umrdr::Forms::WorkForm
    self.model_class = ::GenericWork
    include HydraEditor::Form::Permissions
    self.terms += [:resource_type, :date_coverage]
    self.required_fields = [ :title, :creator, :methodology, :description, :rights, :subject ]

    def rendered_terms
      [ :title, :creator, :methodology, :description, :date_coverage, :rights, :subject, :keyword, :language, :resource_type ]
    end

  end
end
