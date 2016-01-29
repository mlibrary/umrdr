# Generated via
#  `rails generate curation_concerns:work GenericWork`
require 'rails_helper'

describe GenericWork do
  it 'is open visibility by default.' do
    expect(subject.visibility).to eq 'open'
  end
end
