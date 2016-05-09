# Generated via
#  `rails generate curation_concerns:work GenericWork`
module CurationConcerns
  class GenericWorkForm < Umrdr::Forms::WorkForm
    self.model_class = ::GenericWork
    include HydraEditor::Form::Permissions
    self.terms += [:resource_type, :date_coverage_from, :date_coverage_to]
    self.required_fields = [ :title, :creator, :methodology, :description, :rights, :subject ]

    def rendered_terms
      [ :title, :creator, :contributor, :methodology, :description, :date_coverage_from, :rights, :subject, :tag, :language, :resource_type ]
    end

  end
end
