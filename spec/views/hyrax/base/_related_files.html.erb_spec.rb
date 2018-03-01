require 'rails_helper'
require 'rspec/expectations'

describe 'hyrax/base/_related_files.html.erb', type: :view do
  include RSpecHtmlMatchers

  let(:ability) { double( "ability", can?: true ) }
  let(:request) { nil }

  let(:blacklight_configuration_context) do
    Blacklight::Configuration::Context.new(controller)
  end

  before do
    stub_template 'hyrax/base/_member.html.erb' => '<!-- hyrax/base/_member.html.erb -->'
    allow(view).to receive(:blacklight_config).and_return(Blacklight::Configuration.new)
    allow(view).to receive(:blacklight_configuration_context).and_return(blacklight_configuration_context)
  end

  context "with no files and can edit" do
    let(:solr_document) do
      SolrDocument.new(id: '999',
                       has_model_ssim: ['FileSet'],
                       # active_fedora_model_ssi: 'FileSet',
                       # thumbnail_path_ss: '/downloads/999?file=thumbnail',
                       # representative_tesim: ["999"],
                       # title_tesim: ["My File"],
                       # file_size_lts: [99],
                       tombstone: nil )
    end
    let(:presenter) { ::Umrdr::WorkShowPresenter.new(solr_document, ability, request) }
    let(:file_set_presenters) { ::Hyrax::MemberPresenterFactory.new(solr_document, ability, request) }
    let(:member_presenter_factory) { ::Hyrax::MemberPresenterFactory.new( solr_document, ability, request ) }
    let(:file_set_ids) { [] }
    #let(:composite_presenter_class) { ::Hyrax::CompositePresenterFactory.new(::Umrdr::FileSetPresenter, ::Umrdr::WorkShowPresenter, file_set_ids) }
    let(:member_presenters) { [] }

    before do
      allow(view).to receive(:can?).with(:edit, kind_of(String)).and_return(true)
      assign(:presenter, presenter)
      allow(presenter).to receive(:file_set_presenters).and_return( file_set_presenters )
      allow(presenter).to receive(:member_presenter_factory).and_return( member_presenter_factory )
      allow( presenter ).to receive( :box_link_display_for_work? ).and_return( false )
      allow(file_set_presenters).to receive(:present?).and_return( false )
      allow(member_presenter_factory).to receive(:ordered_ids).and_return( file_set_ids )
      allow(member_presenter_factory).to receive(:file_set_ids).and_return( file_set_ids )
      allow(member_presenter_factory).to receive(:member_presenters).and_return( member_presenters )
      render 'hyrax/base/related_files.html.erb', member: presenter
    end

    it 'renders the view' do
      # puts '====='
      # puts rendered
      # puts '====='

      expect(rendered).to have_tag( 'div', count: 3 )
      expect(rendered).to have_tag( 'div', with: {class: "panel panel-default related_files"} )
      expect(rendered).to have_tag( 'div', with: {class: "panel-heading"} )
      expect(rendered).to have_tag( 'h2', :count => 1, text: 'Files' )
      expect(rendered).to have_tag( 'div', with: {class: "alert alert-block alert-warning"} )
      expect(rendered).to have_tag( 'p', :count => 1, with: {class: "center"}, text: 'This  has no files associated with it.' )

      expect(rendered).to_not have_tag( 'table' )
      expect(rendered).to_not have_tag( 'form' )
      # TODO: forms
    end
  end

  context "with one file" do
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

    let(:presenter) { ::Umrdr::WorkShowPresenter.new(solr_document, ability, request) }
    let(:file_set_presenters) { ::Hyrax::MemberPresenterFactory.new(solr_document, ability, request) }
    let(:member_presenter_factory) { ::Hyrax::MemberPresenterFactory.new( solr_document, ability, request ) }
    let(:file_set_ids) { ['999'] }
    let(:composite_presenter_class) { ::Hyrax::CompositePresenterFactory.new(::Umrdr::FileSetPresenter, ::Umrdr::WorkShowPresenter, file_set_ids) }
    let(:member_presenters) { [composite_presenter_class.new(solr_document, [ability, request] )] }

    before do
      assign(:presenter, presenter)
      allow(presenter).to receive(:file_set_presenters).and_return( file_set_presenters )
      allow(presenter).to receive(:member_presenter_factory).and_return( member_presenter_factory )
      allow( presenter ).to receive( :box_link_display_for_work? ).and_return( false )
      allow( ability ).to receive( :admin? ).and_return( false )
      allow(member_presenter_factory).to receive(:ordered_ids).and_return( file_set_ids )
      allow(member_presenter_factory).to receive(:file_set_ids).and_return( file_set_ids )
      allow(member_presenter_factory).to receive(:member_presenters).and_return( member_presenters )
      render 'hyrax/base/related_files.html.erb', member: presenter
    end

    it 'renders the view' do
      # puts '====='
      # puts rendered
      # puts '====='

      expect(rendered).to have_tag( 'div', count: 2 )
      expect(rendered).to have_tag( 'div', with: {class: "panel panel-default related_files"} )
      expect(rendered).to have_tag( 'div', with: {class: "panel-heading"} )
      expect(rendered).to have_tag( 'h2', count: 1, text: 'Files' )
      expect(rendered).to have_tag( 'table', count: 1, with: {class: "table table-striped"} )
      expect(rendered).to have_tag( 'thead', count: 1 )
      expect(rendered).to have_tag( 'tr', count: 1 )
      expect(rendered).to have_tag( 'th', count: 6 )
      expect(rendered).to have_tag( 'th', text: 'File' )
      expect(rendered).to have_tag( 'th', text: 'Filename' )
      expect(rendered).to have_tag( 'th', text: 'Date Uploaded' )
      expect(rendered).to have_tag( 'th', text: 'File Size' )
      expect(rendered).to have_tag( 'th', text: 'Access' )
      expect(rendered).to have_tag( 'th', text: 'Actions' )

      expect(rendered).to have_tag( 'form', count: 4 )
      # TODO: forms
    end
  end

end
