require 'rails_helper'

describe "dashboard/_index_partials/_stats.html.erb"  do

  let!(:user) { stub_model(User, user_key: 'mjg') }
 
    before do
      allow(view).to receive(:current_user).and_return(user)
      assign(:user, user) 
      allow(user).to receive(:total_file_views).and_return(1)
      allow(user).to receive(:total_file_downloads).and_return(3)
    end

    it "returns stats information for user" do

      allow(view).to receive(:number_of_files) { 10 }
      allow(view).to receive(:number_of_collections) { 20 }

      render

      expect(rendered).to have_content "1 View"
      expect(rendered).to have_content "3 Downloads"
      expect(rendered).to have_content "20 Collections"
      expect(rendered).to have_content "10 Files"

    end
    
end