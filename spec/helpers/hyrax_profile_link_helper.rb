require 'rails_helper'

describe HyraxHelper, :type => :helper do

  describe "#link_to_profile" do
    let(:four_users) do
      users = []
      (1..4).each do |i|
        users << stub_model(User, user_key: "user_#{i.to_s}@example.edu", name: "User #{i}", created_at: Time.now, department: 'Potions')
      end
      users
    end

    before do
      assign(:four_users, four_users)
      four_users.each do |one_user|
        one_user.save
      end
    end

    it "correctly escapes email addresses in URLs" do
      four_users.each do |one_user|
        link = link_to_profile one_user.user_key
        expect(link).to include(user.to_param)
      end
    end

    it "no longer incorrectly escapes email addresses in URLs" do
      four_users.each do |one_user|
        link = link_to_profile one_user.user_key
        expect(link).not_to include(user.user_key)
      end
    end
  end

end