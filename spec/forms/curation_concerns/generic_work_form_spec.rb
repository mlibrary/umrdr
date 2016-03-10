# Generated via
#  `rails generate curation_concerns:work GenericWork`
require 'rails_helper'

describe CurationConcerns::GenericWorkForm do

  let(:ability) { double }

  describe "check for minted identifiers" do

    let(:form) { described_class.new(stub_model(GenericWork, id: '456', doi: 'doi:10.1000/182'), ability) }

    it "should return true that a DOI has been minted" do
      expect(form.identifiers_minted?(:doi)).to be_truthy
    end
  end

  describe "check for unminted identifiers" do
    let(:form) { described_class.new(stub_model(GenericWork, id: '456'), ability)}

    it "should return false that a DOI has been minted" do
      expect(form.identifiers_minted?(:doi)).to be_falsey
    end
  end

end

