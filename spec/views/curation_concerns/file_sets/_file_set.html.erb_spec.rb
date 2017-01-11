require 'spec_helper'

describe 'curation_concerns/file_sets/_file_set.html.erb' do
  let(:solr_document) { SolrDocument.new(id: '999',
                                         has_model_ssim: ['FileSet'],
                                         active_fedora_model_ssi: 'FileSet',
                                         thumbnail_path_ss: '/downloads/999?file=thumbnail',
                                         representative_tesim: ["999"],
                                         title_tesim: ["My File"]) }

  # Ability is checked in FileSetPresenter#link_name
  let(:ability) { double(can?: true) }
  let(:presenter) { CurationConcerns::FileSetPresenter.new(solr_document, ability) } 
  let(:blacklight_configuration_context) do
    Blacklight::Configuration::Context.new(controller)
  end

  before do
    assign(:presenter, presenter)
    allow(view).to receive(:blacklight_configuration_context).and_return(blacklight_configuration_context)
    allow(view).to receive(:blacklight_config).and_return(CatalogController.blacklight_config)
    allow(view).to receive(:current_search_session).and_return nil
    allow(view).to receive(:search_session).and_return({})
    # abilities called in _actions.html.erb
    allow(view).to receive(:can?).with(:read, kind_of(String)).and_return(true)
    allow(view).to receive(:can?).with(:edit, kind_of(String)).and_return(true)
    allow(view).to receive(:can?).with(:destroy, String).and_return(true)
    allow(presenter).to receive(:identifiers_minted?).with(:doi).and_return(false)
    render 'curation_concerns/file_sets/file_set.html.erb', file_set: presenter
  end

  it 'renders the view' do
    # A thumbnail
    expect(rendered).to have_selector ".thumbnail img[src='#{download_path(presenter, file: 'thumbnail')}']"

    # View Details link
    expect(rendered).to have_link('View Details')

  end
end
