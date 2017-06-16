require 'rails_helper'

describe Hyrax::GenericWorksController do
  let(:user) { FactoryGirl.build(:user) }
  let(:work) { FactoryGirl.build(:generic_work, id: '123', title: ['test title'], user: user) }

  describe "#mint_doi" do
    context "handling a work that has a File Set." do
      let(:file_set) { FactoryGirl.build(:file_set, label: 'myfile', id: 'fs456') }

      before do
        allow(work).to receive(:file_sets).and_return([file_set])
        allow(controller).to receive(:curation_concern).and_return(work)
      end

      it "allows a doi to be minted." do
        expect(DoiMintingJob).to receive(:perform_later)
        controller.mint_doi
      end
    end

    context "handling a work that does not have a File Set." do
      before do
        allow(controller).to receive(:curation_concern).and_return(work)
      end

      it "displays a flash message instead of mintng a doi." do
        expect(DoiMintingJob).not_to receive(:perform_later)
        controller.mint_doi
        expect(flash[:notice]).to eq("DOI cannot be minted for a work without files.")
      end
    end
  end
end
