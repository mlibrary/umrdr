require 'rails_helper'

describe "View Landing Page", type: :feature do
  before do
    visit "/"
  end

  it "renders the home page text" do
    expect(page).to have_content("Deep Blue Data")
  end
end
