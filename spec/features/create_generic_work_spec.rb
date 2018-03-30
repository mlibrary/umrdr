require 'rails_helper'

# Skipping because this was failing intermittently on travis (same as create_work_spec from upstream)
RSpec.feature 'Create a GenericWork', :workflow, skip: true do
  include Warden::Test::Helpers
  context 'a logged in user' do
    let(:user_attributes) do
      { email: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end

    before do
      login_as user
    end

    scenario do
      visit new_hyrax_generic_work_path
      fill_in 'Title', with: 'Test GenericWork'
      fill_in 'Creator', with: 'Creator, Test'
      fill_in 'Method', with: 'Test'
      fill_in 'Description', with: 'Test'
      fill_in 'Contact Information', with: 'abc@umich.edu'
      choose 'generic_work_rights_httpcreativecommonsorgpublicdomainzero10'
      select 'Other', from: 'generic_work_subject'
      click_button 'Publish'
      expect(page).to have_content 'Test GenericWork'
      expect(page).to have_content 'Creator, Test'
    end
  end
end
