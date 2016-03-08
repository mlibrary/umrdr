require 'spec_helper'
require 'rails_helper'

describe 'curation_concerns/base/_identifiers.html.erb', type: :view do

  let(:user) { stub_model(User) }

  describe "work does not have a DOI" do
    let(:object_profile) { [{ id: "999", doi: nil }.to_json] }
    let(:solr_document) {
      SolrDocument.new(
        id: '999',
        object_profile_ssm: object_profile,
        has_model_ssim: ['GenericWork'],
        human_readable_type_tesim: ['Work'],
        rights_tesim: ['http://creativecommons.org/licenses/by/3.0/us/']
      )
    }
    let(:ability) { Ability.new(user) }
    let(:presenter) { Umrdr::WorkShowPresenter.new(solr_document, ability) }
    before do
      assign(:presenter, presenter)
      allow(controller).to receive(:can?).with(:edit, presenter.id).and_return(true)
      render partial: "curation_concerns/base/identifiers"
    end

    it "should render a Mint DOI action" do
      expect(rendered).to have_selector(:xpath, "//input[@type='submit'][@value='Mint DOI']", count: 1)
    end

    it "should warn about editing and DOI persistence" do
      expect(rendered).to have_content(I18n.t('simple_form.warnings.generic_work.mint_doi'))
    end
  end

  describe "work has a DOI" do
    let(:doi) { 'doi:10.1000/182' }
    let(:object_profile) { [{ id: "999", doi: doi }.to_json] }
    let(:solr_document) {
      SolrDocument.new(
        id: '999',
        object_profile_ssm: object_profile,
        has_model_ssim: ['GenericWork'],
        human_readable_type_tesim: ['Work'],
        rights_tesim: ['http://creativecommons.org/licenses/by/3.0/us/']
      )
    }
    let(:ability) { Ability.new(user) }
    let(:presenter) { Umrdr::WorkShowPresenter.new(solr_document, ability) }
    before do
      assign(:presenter, presenter)
      allow(controller).to receive(:can?).with(:edit, presenter.id).and_return(true)
      render partial: "curation_concerns/base/identifiers"
    end

    it "should not render a Mint DOI action" do
      ### this fails all the time
      # expect(rendered).to have_no_selector(:xpath, "//input[@type='submit'][@value='Mint DOI']")
      expect(rendered).to have_selector(:xpath, "//input[@type='submit'][@value='Mint DOI']", count: 0)
    end

    it "present the DOI" do
      expect(rendered).to have_content(doi)
    end
  end

end
