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

  context 'validations' do
    before do
      subject.title = ['Demotitle']
      subject.creator = ['Demo Creator']
      subject.date_created = ['2016-02-28']
      subject.description = ['Demo description.']
    end

    it 'validates title' do
      subject.title = nil
      expect(subject).not_to be_valid
    end

    it 'validates date_created' do
      subject.date_created = nil
      expect(subject).not_to be_valid
    end

    it 'validates description' do
      subject.description = nil
      expect(subject).not_to be_valid
    end

    it 'validates creator' do
      subject.creator = nil
      expect(subject).not_to be_valid
    end
  end
end
