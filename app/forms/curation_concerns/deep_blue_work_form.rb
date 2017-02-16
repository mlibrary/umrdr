# Generated via
#  `rails generate curation_concerns:work DeepBlueWork`
module CurationConcerns
  class DeepBlueWorkForm < Sufia::Forms::WorkForm
    self.model_class = ::DeepBlueWork
    self.terms += [:resource_type]

  end
end
