# Generated via
#  `rails generate curation_concerns:work GenericWork`
module CurationConcerns
  class GenericWorkForm < Sufia::Forms::WorkForm
    self.model_class = ::GenericWork
    include HydraEditor::Form::Permissions
    self.terms += [:resource_type]
    self.required_fields = [ :title, :creator, :date_created, :methodology, :description, :rights ]

    def rendered_terms
      [ :title, :creator, :contributor, :methodology, :description, :date_created, :rights, :subject, :tag, :language, :identifier, :resource_type ]
    end

  end
end
