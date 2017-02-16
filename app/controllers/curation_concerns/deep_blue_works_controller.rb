# Generated via
#  `rails generate curation_concerns:work DeepBlueWork`

module CurationConcerns
  class DeepBlueWorksController < ApplicationController
    include CurationConcerns::CurationConcernController
    # Adds Sufia behaviors to the controller.
    include Sufia::WorksControllerBehavior

    self.curation_concern_type = DeepBlueWork
  end
end
