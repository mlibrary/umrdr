require 'spec_helper'

describe 'hyrax/base/show.html.erb', type: :view do

  let(:solr_document) do
    SolrDocument.new(id: '999',
                     date_modified_dtsi: '2011-04-01',
                     has_model_ssim: ['GenericWork'])
  end
  let(:ability) { double }
  let(:presenter) do
    Hyrax::WorkShowPresenter.new(solr_document, ability)
  end

  before do
    stub_template 'hyrax/base/_attributes.html.erb' => 'hyrax/base/_attributes.html.erb'
    stub_template 'hyrax/base/_browse_everything.html.erb' => 'hyrax/base/_browse_everything.html.erb'
    stub_template 'shared/_citations.html.erb' => 'shared/_citations.html.erb'
    stub_template 'hyrax/file_sets/_multiple_upload.html.erb' => 'hyrax/file_sets/_multiple_upload.html.erb'
    stub_template 'hyrax/base/_recent_uploads.html.erb' => 'hyrax/base/_recent_uploads.html.erb'
    stub_template 'hyrax/base/_related_files.html.erb' => 'hyrax/base/_related_files.html.erb'
    stub_template 'hyrax/base/_show_actions.html.erb' => 'hyrax/base/_show_actions.html.erb'
  end

  context 'no edit' do
    let(:page) { Capybara::Node::Simple.new(rendered) }

    before do
      allow(view).to receive(:can?).with(:collect, kind_of(String)).and_return(false)
      allow(view).to receive(:can?).with(:edit, kind_of(String)).and_return(false)
      allow(presenter).to receive(:editor?).and_return(false)
      assign(:presenter, presenter)
      render
    end

    it 'is empty' do
      # puts '====='
      # puts rendered
      # puts '====='

      expect(page).to have_content 'shared/_citations.html.erb'
      expect(page).to have_content 'hyrax/base/_recent_uploads.html.erb'
      expect(page).to have_content 'hyrax/base/_attributes.html.erb'
      expect(page).to have_content 'hyrax/base/_related_files.html.erb'
      expect(page).not_to have_content 'hyrax/file_sets/_multiple_upload.html.erb'
      expect(page).to have_content 'hyrax/base/_show_actions.html.erb'

    end
  end

  context 'editor' do
    let(:page) { Capybara::Node::Simple.new(rendered) }

    before do
      allow(view).to receive(:can?).with(:collect, kind_of(String)).and_return(false)
      allow(view).to receive(:can?).with(:edit, kind_of(String)).and_return(true)
      allow(presenter).to receive(:editor?).and_return(true)
      assign(:presenter, presenter)
      render
    end

    it 'allows edit' do
      # puts '====='
      # puts rendered
      # puts '====='

      expect(page).to have_content 'shared/_citations.html.erb'
      expect(page).to have_content 'hyrax/base/_recent_uploads.html.erb'
      expect(page).to have_content 'hyrax/base/_attributes.html.erb'
      expect(page).to have_content 'hyrax/base/_related_files.html.erb'
      expect(page).to have_content 'hyrax/file_sets/_multiple_upload.html.erb'
      expect(page).to have_content 'hyrax/base/_show_actions.html.erb'
    end
  end

  # TODO
  # describe 'Showing a Generic Work with zero FileSets' do
  #   let(:generic_work) { GenericWork.new(id: '456', title: ['Containing work']) }
  #   let(:user) {User.new(email:'demo@demo.com', id: 'user1')}
  #   let(:ability) {Ability.new(user)}
  #   let(:work_presenter) {Umrdr::WorkShowPresenter.new(solr_doc, ability, nil)}
  #
  #   it 'renders links to all member FileSets' do
  #     skip 'mock presenter and request context sufficiently to test that links to files appear'
  #     # Presenters are created from PresenterFactory in the application
  #   end
  # end
  #
  # describe 'Showing a Generic Work with more than 10 attached FileSets' do
  # end

end