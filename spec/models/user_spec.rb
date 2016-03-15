require 'rails_helper'

RSpec.describe User, type: :model do
  context "when a user is created it" do
    it "can be created with just an email parameter" do
      u1 = User.create(email: "name@blah.com")
      expect(u1).to be_an_instance_of(User)
      expect(u1.email).to eq("name@blah.com")
    end

    it "doesn't generate a password when called with new" do
      u2 = User.new
      expect(u2.password).to be_nil
    end

    it "doesn't save without a password" do
      u3 = User.new
      expect(u3.save).to be_falsey
    end

    it "can generate a password" do
      u4 = User.new(email: "name2@blah.com")
      expect(u4.password).to be_nil
      u4.generate_password
      expect(u4.password).to_not be_nil
      expect(u4.password).to be_kind_of String
      expect(u4.password_confirmation).to be_kind_of String
      expect(u4.password).to eq(u4.password_confirmation)
    end
  end
end