require 'rails_helper'
require 'rspec/expectations'

describe 'hyrax/base/_identifiers.html.erb', type: :view do
  include RSpecHtmlMatchers

  let(:ability) { double(can?: true) }

  let(:blacklight_configuration_context) do
    Blacklight::Configuration::Context.new(controller)
  end

  before do
    allow(view).to receive(:blacklight_config).and_return(Blacklight::Configuration.new)
    allow(view).to receive(:blacklight_configuration_context).and_return(blacklight_configuration_context)
  end

  context "no doi" do
    let(:solr_document) do
      SolrDocument.new(id: '999',
                       has_model_ssim: ['FileSet'],
                       active_fedora_model_ssi: 'FileSet',
                       thumbnail_path_ss: '/downloads/999?file=thumbnail',
                       representative_tesim: ["999"],
                       title_tesim: ["My File"],
                       file_size_lts: [99],
                       tombstone: nil,
                       doi: nil
                       )
    end

    let(:presenter) { Umrdr::WorkShowPresenter.new(solr_document, ability, nil) }

    before do
      assign(:presenter, presenter)
      # allow(view).to receive(:contextual_path).with(anything, anything) do |x, y|
      #   Hyrax::ContextualPath.new(x, y).show
      # end
      render 'hyrax/base/identifiers.html.erb', member: presenter
    end

    it 'renders the view' do
      # puts '====='
      # puts rendered
      # puts '====='

      expect(rendered).to eq( "" )
    end
  end

  context "with doi" do
    let(:solr_document) do
      SolrDocument.new(id: '999',
                       has_model_ssim: ['FileSet'],
                       active_fedora_model_ssi: 'FileSet',
                       thumbnail_path_ss: '/downloads/999?file=thumbnail',
                       representative_tesim: ["999"],
                       title_tesim: ["My File"],
                       file_size_lts: [99],
                       tombstone: nil,
                       doi_ssim: ['xDoi'] )
    end

    let(:presenter) { Umrdr::WorkShowPresenter.new(solr_document, ability, nil) }

    before do
      assign(:presenter, presenter)
      # allow(view).to receive(:contextual_path).with(anything, anything) do |x, y|
      #   Hyrax::ContextualPath.new(x, y).show
      # end
      render 'hyrax/base/identifiers.html.erb', member: presenter
    end

    it 'renders the view' do
      # puts '====='
      # puts rendered
      # puts '====='

      expect(rendered).to have_tag( 'tr', count: 1 )
      expect(rendered).to have_tag( 'th', count: 1, text: "DOI" )
      expect(rendered).to have_tag( 'td', count: 1 )
      expect(rendered).to have_tag( 'ul', count: 1, with: {class: "tabular"} )
      expect(rendered).to have_tag( 'li', count: 1, with: {class: "attribute"} )
      expect(rendered).to have_tag( 'span', count: 1, with: {class: "label label-default"}, text: 'xDoi' )
    end
  end

end