require 'rails_helper'

describe "View Landing Page", type: :feature do
  before do
    visit "/"
  end

  it "renders the home page text" do
    expect(page).to have_content("Featured Researcher")
  end

  it "references script assests with respect to application root" do
    page.all('script', visible: false).each do |r|
      expect(r[:src]).to start_with('/data/assets')
    end
  end
end
