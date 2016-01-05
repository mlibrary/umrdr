# Generated via
#  `rails generate curation_concerns:work SciWork`

class CurationConcerns::SciWorksController < ApplicationController
  include CurationConcerns::CurationConcernController
  set_curation_concern_type SciWork
end
