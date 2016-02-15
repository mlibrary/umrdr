# Generated via
#  `rails generate curation_concerns:work GenericWork`

class CurationConcerns::GenericWorksController < ApplicationController
  include CurationConcerns::CurationConcernController
  # Adds Sufia behaviors to the controller.
  include Sufia::WorksControllerBehavior

  set_curation_concern_type GenericWork

  # override setup_form to add build_form.
  # Until curation_concerns/#614 is resolved.
  def setup_form
    build_form
    super
  end
end
