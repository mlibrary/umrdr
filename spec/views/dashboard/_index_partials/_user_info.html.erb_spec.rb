require 'rails_helper'

describe "dashboard/_index_partials/_user_info.html.erb"  do

  let!(:user) { stub_model(User, user_key: 'mjg') }
 
    before do
      allow(view).to receive(:current_user).and_return(user)
      assign(:user, user) 
      allow(user).to receive(:email).and_return( "abc@umich.edu" )
    end

    it "returns user status info" do

      render

      expect(rendered).to have_content "My Profile abc@umich.edu"
      expect(rendered).to have_content "View Profile"
      expect(rendered).to have_content "Edit Profile"

    end

end