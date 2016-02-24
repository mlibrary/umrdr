# Generated via
#  `rails generate curation_concerns:work GenericWork`

require 'pp'
class CurationConcerns::GenericWorksController < ApplicationController
  include CurationConcerns::CurationConcernController
  # Adds Sufia behaviors to the controller.
  include Sufia::WorksControllerBehavior

  before_action :check_recent_uploads, only: [:show]

  set_curation_concern_type GenericWork

  def check_recent_uploads
    if params[:since]
      begin
        since = params[:since].to_i
        presenter.file_presenters.each do |what|
          pp(what, STDERR)
        end
      rescue
      end
    end
  end

end
