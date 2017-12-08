require 'rails_helper'
require 'rspec/expectations'

describe 'hyrax/base/_member.html.erb', type: :view do
  include RSpecHtmlMatchers

  let(:solr_document) do
    SolrDocument.new(id: '999',
                     has_model_ssim: ['FileSet'],
                     active_fedora_model_ssi: 'FileSet',
                     thumbnail_path_ss: '/downloads/999?file=thumbnail',
                     representative_tesim: ["999"],
                     title_tesim: ["My File"],
                     file_size_lts: [99],
                     tombstone: nil )
  end

  let(:ability) { double(can?: true) }
  let(:presenter) { Umrdr::WorkShowPresenter.new(solr_document, ability, nil) }

  let(:blacklight_configuration_context) do
    Blacklight::Configuration::Context.new(controller)
  end

  before do
    assign(:presenter, presenter)
    allow(view).to receive(:blacklight_config).and_return(Blacklight::Configuration.new)
    allow(view).to receive(:blacklight_configuration_context).and_return(blacklight_configuration_context)
    allow(view).to receive(:can?).with(:read, kind_of(String)).and_return(true)
    allow(view).to receive(:can?).with(:edit, kind_of(String)).and_return(true)
    allow(view).to receive(:can?).with(:destroy, String).and_return(true)
    allow(view).to receive(:contextual_path).with(anything, anything) do |x, y|
      Hyrax::ContextualPath.new(x, y).show
    end
    render 'hyrax/base/member.html.erb', member: presenter
  end

  it 'renders the view' do
    # puts '====='
    # puts rendered
    # puts '====='

    expect(rendered).to have_tag( 'tr', count: 1, with: {class: "file_set attributes"} )
    expect(rendered).to have_tag( 'td', count: 6 )
    #expect(rendered).to have_selector ".thumbnail img[src='#{hyrax.download_path(presenter, file: 'thumbnail')}']"
    expect(rendered).to have_tag( 'td', with: {class: "thumbnail"} ) # :text => "\n" ??
    expect(rendered).to have_selector( "a[href='#{hyrax.download_path(presenter)}']", text: 'My File' )
    expect(rendered).to have_tag( 'td', with: {class: "attribute date_uploaded"}, text: '' )
    expect(rendered).to have_tag( 'td', with: {class: "attribute size"}, text: '99 Bytes' )
    expect(rendered).to have_tag( 'span', with: {class: "label label-danger"}, text: 'Draft' )
    expect(rendered).to have_selector( "a[href='/concern/parent/999/file_sets/999']", text: 'View Details' )
    #expect(rendered).to have_selector( "a[href='#{edit_polymorphic_path(presenter)}']", text: 'View Details' )
  end
end