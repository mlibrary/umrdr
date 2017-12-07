require 'spec_helper'

require 'rails_helper'
require 'rspec/expectations'

describe 'hyrax/base/_attributes.html.erb', type: :view do
  include RSpecHtmlMatchers

  let(:ability) { double(can?: true) }

  let(:blacklight_configuration_context) do
    Blacklight::Configuration::Context.new(controller)
  end

  before do
    allow(view).to receive(:blacklight_config).and_return(Blacklight::Configuration.new)
    allow(view).to receive(:blacklight_configuration_context).and_return(blacklight_configuration_context)
    stub_template 'hyrax/base/_attribute_rows.html.erb' => 'hyrax/base/_attribute_rows.html.erb'
  end

  context "with doi" do
    let(:solr_document) do
      SolrDocument.new(id: '999',
                       has_model_ssim: ['FileSet'],
                       active_fedora_model_ssi: 'FileSet',
                       thumbnail_path_ss: '/downloads/999?file=thumbnail',
                       title_tesim: ["My File"],
                       embargo_release_date_dtsi: '2018-12-01',
                       lease_expiration_date_dtsi: '2017-12-01',
                       rights_tesim: [ "Rights999" ] )
    end

    let(:presenter) { Umrdr::WorkShowPresenter.new(solr_document, ability, nil) }

    before do
      assign(:presenter, presenter)
      allow(presenter).to receive(:total_file_count).and_return( 1 )
      allow(view).to receive(:contextual_path).with(anything, anything) do |x, y|
        Hyrax::ContextualPath.new(x, y).show
      end
      render 'hyrax/base/attributes.html.erb', member: presenter
    end

    it 'renders the view' do
      # puts '====='
      # puts rendered
      # puts '====='

      element_count = 4
      expect(rendered).to have_tag( 'table', count: 1, with: {class: "table table-striped file_set attributes", itemscope: '', itemtype: "http://schema.org/CreativeWork"} )
      expect(rendered).to have_tag( 'caption', count: 1, with: { class: "table-heading" } )
      expect(rendered).to have_tag( 'h2', count: 1, text: "Work Description:" )
      expect(rendered).to have_tag( 'thead', count: 1 )
      expect(rendered).to have_tag( 'th', count: 3 + element_count )
      expect(rendered).to have_tag( 'th', with: { colspan: 2 }, text: "Title: My File" )
      expect(rendered).to have_tag( 'th', text: "Attribute Name" )
      expect(rendered).to have_tag( 'th', text: "Values" )
      expect(rendered).to have_tag( 'tbody', count: 1 )

      expect(rendered).to have_tag( 'tr', count: 2 + element_count )
      expect(rendered).to have_tag( 'td', count: element_count )
      expect(rendered).to have_tag( 'ul', count: element_count )
      expect(rendered).to have_tag( 'li', count: element_count )
      expect(rendered).to have_tag( 'ul', count: element_count, with: { class: "tabular" } )

      expect(rendered).to have_tag( 'th', text: "Visibility" )
      expect(rendered).to have_tag( 'li', with: { class: "attribute permission_badge" } )
      expect(rendered).to have_tag( 'span', with: { class: "label label-danger", title: "Draft" }, text: 'Draft' )

      expect(rendered).to have_tag( 'th', text: "Embargo release date" )
      expect(rendered).to have_tag( 'li', with: { class: "attribute embargo_release_date" }, text: "2018-12-01" )

      expect(rendered).to have_tag( 'th', text: "Lease expiration date" )
      expect(rendered).to have_tag( 'li', with: { class: "attribute lease_expiration_date" }, text: "2017-12-01" )

      expect(rendered).to have_tag( 'th', text: "Rights" )
      expect(rendered).to have_tag( 'li', with: { class: "attribute rights" }, text: "Rights999" )

      expect(rendered).to have_content( 'hyrax/base/_attribute_rows.html.erb' )
    end
  end

  # TODO: with tombstone

end