# Generated via
#  `rails generate curation_concerns:work GenericWork`
require 'rails_helper'

describe GenericWork do
  it 'is open visibility by default.' do
    expect(subject.visibility).to eq 'open'
  end

  it 'it cannot be set to anything other than open visibility.' do
    subject.visibility='restricted'
    expect(subject.visibility).to eq 'open'
  end
end
