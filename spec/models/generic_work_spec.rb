# Generated via
#  `rails generate curation_concerns:work GenericWork`
require 'rails_helper'

describe GenericWork do
  let(:instance){subject.new}
  it 'is open visibility by default.' do
    expect(instance.visibility).to_eq 'open'
  end
end
