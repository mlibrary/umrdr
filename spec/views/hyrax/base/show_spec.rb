require 'rails_helper'

describe 'hyrax/base/show' do
  describe 'Showing a Generic Work with zero FileSets' do
    let(:generic_work) { GenericWork.new(id: '456', title: ['Containing work']) }
    let(:user) {User.new(email:'demo@demo.com', id: 'user1')}
    let(:ability) {Ability.new(user)}
    let(:work_presenter) {Umrdr::WorkShowPresenter.new(solr_doc, ability, nil)}

    it 'renders links to all member FileSets' do
      skip 'mock presenter and request context sufficiently to test that links to files appear'
      # Presenters are created from PresenterFactory in the application
    end
  end

  describe 'Showing a Generic Work with more than 10 attached FileSets' do
  end
end
