require 'rails_helper'
require 'rspec/expectations'

describe 'hyrax/base/_attribute_rows.html.erb', type: :view do
  include RSpecHtmlMatchers

  let(:ability) { double(can?: true) }

  let(:blacklight_configuration_context) do
    Blacklight::Configuration::Context.new(controller)
  end

  before do
    allow(view).to receive(:blacklight_config).and_return(Blacklight::Configuration.new)
    allow(view).to receive(:blacklight_configuration_context).and_return(blacklight_configuration_context)
    stub_template 'hyrax/base/_identifiers.html.erb' => 'hyrax/base/_identifiers.html.erb'
  end

  context "with doi" do
    let(:solr_document) do
      SolrDocument.new(id: '999',
                       has_model_ssim: ['FileSet'],
                       active_fedora_model_ssi: 'FileSet',
                       thumbnail_path_ss: '/downloads/999?file=thumbnail',
                       representative_tesim: ["999"],
                       date_modified_dtsi: '2017-12-01',
                       title_tesim: ["My File"],
                       file_size_lts: [99],
                       description_tesim: [ "Description999" ],
                       methodology_tesim: [ "Methodology999" ],
                       creator_tesim: [ "Creator999" ],
                       authoremail_tesim: [ "author@email.edu" ],
                       contributor_tesim: [ "Contributor999" ],
                       subject_tesim: [ "Subject999" ],
                       fundedby_tesim: [ "Fundedby999" ],
                       grantnumber_tesim: [ "Grantnumber999" ],
                       keyword_tesim: [ "Keyword999" ],
                       date_coverage_tesim: [ "DateCoverage999" ],
                       isReferencedBy_tesim: [ "isReferencedBy999" ],
                       publisher_tesim: [ "Publisher999" ],
                       language_tesim: [ "Language999" ],
                       total_file_size_lts: [999],
                       tombstone_ssim: nil,
                       doi_ssim: ['xDoi'] )
    end

    let(:presenter) { Umrdr::WorkShowPresenter.new(solr_document, ability, nil) }

    before do
      assign(:presenter, presenter)
      allow(presenter).to receive(:total_file_count).and_return( 1 )
      allow(view).to receive(:contextual_path).with(anything, anything) do |x, y|
        Hyrax::ContextualPath.new(x, y).show
      end
      render 'hyrax/base/attribute_rows.html.erb', member: presenter
    end

    it 'renders the view' do
      # puts '====='
      # puts rendered
      # puts '====='

      expected_row_count = 15
      expect(rendered).to have_tag( 'tr', count: expected_row_count )
      expect(rendered).to have_tag( 'th', count: expected_row_count )
      expect(rendered).to have_tag( 'td', count: expected_row_count )
      expect(rendered).to have_tag( 'ul', count: expected_row_count, with: {class: "tabular"} )
      expect(rendered).to have_tag( 'li', count: expected_row_count )

      expect(rendered).to have_tag( 'th', text: 'Methodology' )
      expect(rendered).to have_tag( 'li', with: {class: "more"}, text: 'Methodology999' ) # with: {class: "attribute methodology"},

      expect(rendered).to have_tag( 'th', text: 'Description' )
      expect(rendered).to have_tag( 'li', with: {class: "attribute description"} )
      expect(rendered).to have_tag( 'span', with: {class: "more", itemprop: 'description'}, text: 'Description999' )

      expect(rendered).to have_tag( 'th', text: 'Creator' )
      expect(rendered).to have_tag( 'li', with: {class: "attribute creator", itemprop: "creator", itemscope: '', itemtype: "http://schema.org/Person" } )
      expect(rendered).to have_tag( 'span', with: {itemprop: 'name'}, text: 'Creator999' )

      expect(rendered).to have_tag( 'th', text: 'Contact Information' )
      expect(rendered).to have_tag( 'li', with: {class: "attribute authoremail"} )
      expect(rendered).to have_tag( 'a', with: {href: 'mailto:author@email.edu'}, text: 'author@email.edu' )

      expect(rendered).to have_tag( 'th', text: 'Contributors' )
      expect(rendered).to have_tag( 'li', with: {class: "attribute contributor", itemprop: "contributor", itemscope: '', itemtype: "http://schema.org/Person" } )
      expect(rendered).to have_tag( 'span', with: {itemprop: 'name'}, text: 'Contributor999' )

      expect(rendered).to have_tag( 'th', text: 'Discipline' )
      expect(rendered).to have_tag( 'li', with: {class: "attribute subject", itemprop: "about", itemscope: '', itemtype: "http://schema.org/Thing" } )
      expect(rendered).to have_tag( 'span', with: {itemprop: 'name'}, text: 'Subject999' )

      expect(rendered).to have_tag( 'th', text: 'Funding Agency' )
      expect(rendered).to have_tag( 'li', with: {class: "attribute fundedby"}, text: 'Fundedby999' )

      expect(rendered).to have_tag( 'th', text: 'ORSP Grant Number' )
      expect(rendered).to have_tag( 'li', with: {class: "attribute grantnumber"}, text: 'Grantnumber999' )

      expect(rendered).to have_tag( 'th', text: 'Keyword' )
      expect(rendered).to have_tag( 'li', with: {class: "attribute keyword"}, text: 'Keyword999' )

      expect(rendered).to have_tag( 'th', text: 'Date coverage' )
      expect(rendered).to have_tag( 'li', with: {class: "attribute date_coverage"}, text: 'DateCoverage999' )

      expect(rendered).to have_tag( 'th', text: 'Citation to related material' )
      expect(rendered).to have_tag( 'li', with: {class: "attribute isReferencedBy"}, text: 'isReferencedBy999' )

      expect(rendered).to have_tag( 'th', text: 'Publisher' )
      expect(rendered).to have_tag( 'li', with: {class: "attribute publisher", itemprop: "publisher", itemscope: '', itemtype: "http://schema.org/Organization" } )
      expect(rendered).to have_tag( 'span', with: {itemprop: 'name'}, text: 'Publisher999' )

      expect(rendered).to have_tag( 'th', text: 'Language' )
      expect(rendered).to have_tag( 'li', with: {class: "attribute language"} )
      expect(rendered).to have_tag( 'span', with: {itemprop: 'inLanguage'}, text: 'Language999' )

      expect(rendered).to have_tag( 'th', text: 'Total File Count' )
      expect(rendered).to have_tag( 'li', with: {class: "attribute total_file_count"}, text: '1' )

      expect(rendered).to have_tag( 'th', text: 'Total File Size' )
      expect(rendered).to have_tag( 'li', with: {class: "attribute total_file_size_human_readable"}, text: '999' )

      expect(rendered).to have_content( 'hyrax/base/_identifiers.html.erb' )
    end
  end

end