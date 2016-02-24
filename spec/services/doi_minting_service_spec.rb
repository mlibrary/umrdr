require 'rails_helper'

describe Umrdr::DoiMintingService do
  let(:work) {GenericWork.new(id: '123', title: ['demotitle'], 
                              creator: ['person1','person2','person3'])}
  before do
    allow(work).to receive(:save)
  end

  it "mints a doi" do
    skip if ENV['TRAVIS']
    expect(described_class.mint_doi_for(work)).to start_with 'doi:10.5072/FK2' 
  end
end
