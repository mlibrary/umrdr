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

  # describe "#globus" do
  #
  #   context "work with files." do
  #     let(:file_set) { FactoryGirl.build(:file_set, label: 'myfile', id: 'fs456') }
  #
  #     before do
  #       allow(work).to receive(:file_sets).and_return([file_set])
  #       allow(controller).to receive(:curation_concern).and_return(work)
  #     end
  #
  #     it "invokes globus copy job." do
  #       expect(GlobusCopyJob).to receive(:perform_later)
  #       controller.globus
  #     end
  #   end
  #
  #   # context "work without files." do
  #   #   before do
  #   #     allow(controller).to receive(:curation_concern).and_return(work)
  #   #   end
  #   #
  #   # end
  #
  # end

  describe "#globus_url" do
    context "returns a globus url based on curation concern id." do
      let(:file_set) { FactoryGirl.build(:file_set, label: 'myfile', id: 'fs456') }
      before do
        allow(controller).to receive(:curation_concern).and_return(work)
      end
      it "returns a globus url." do
        url = controller.globus_url
        expect( url ).to eq( "https://www.globus.org/app/transfer?origin_id=99d8c648-a9ff-11e7-aedd-22000a92523b&origin_path=%2Fdownload%2FDeepBlueData_123%2F" )
      end
    end
  end

end
