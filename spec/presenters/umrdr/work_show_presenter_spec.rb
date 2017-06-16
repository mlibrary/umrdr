require 'rails_helper'

describe Umrdr::WorkShowPresenter do
  let(:object_profile) { ["{\"id\":\"999\"}"] }
  let(:contributor) { ['Frodo'] }
  let(:creator)     { ['Bilbo'] }
  let(:solr_document) {
    SolrDocument.new(
      id: '999',
      object_profile_ssm: object_profile,
      has_model_ssim: ['GenericWork'],
      human_readable_type_tesim: ['Generic Work'],
      contributor_tesim: contributor,
      creator_tesim: creator,
      rights_tesim: ['http://creativecommons.org/licenses/by/3.0/us/']
    )
  }
  let(:presenter) { described_class.new(solr_document, ability) }

  describe '#itemtype' do
    let(:work) { stub_model(GenericWork, id: nil, depositor: 'bob', rights: ['']) }
    let(:ability) { double "Ability" }

    subject { presenter.itemtype }

    context 'when resource_type is DataSet' do

      it {
        is_expected.to include('http://schema.org/CreativeWork')

         }
      
    end
  end
end
