# Generated via
#  `rails generate curation_concerns:work SciWork`
require 'rails_helper'

describe SciWork do
  context "validation" do
    it do
      should validate_presence_of(:title).
          with_message('Your work must have a title.')
    end
  end
end
