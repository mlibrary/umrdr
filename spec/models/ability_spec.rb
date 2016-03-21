require 'rails_helper'
require 'cancan/matchers'

describe Umrdr::Ability, type: :model do
  describe "a user with no roles" do
    let(:user) { nil }
    subject { Ability.new(user) }
    it { is_expected.not_to be_able_to(:create, FileSet) }
    it { is_expected.not_to be_able_to(:create, TinymceAsset) }
    it { is_expected.not_to be_able_to(:create, ContentBlock) }
    it { is_expected.not_to be_able_to(:update, ContentBlock) }
    it { is_expected.to be_able_to(:read, ContentBlock) }
    it { is_expected.to be_able_to(:view_share_work, FileSet) }
    it { is_expected.to be_able_to(:read, GenericWork) }
    it { is_expected.to be_able_to(:stats, GenericWork) }
    it { is_expected.to be_able_to(:citation, GenericWork) }
  end

  describe "a registered user" do
    let(:user) { stub_model(User, user_key: 'njaffer') }
    subject { Ability.new(user) }
    it { is_expected.to be_able_to(:create, FileSet) }
    it { is_expected.not_to be_able_to(:create, TinymceAsset) }
    it { is_expected.not_to be_able_to(:create, ContentBlock) }
    it { is_expected.not_to be_able_to(:update, ContentBlock) }
    it { is_expected.to be_able_to(:read, ContentBlock) }
    it { is_expected.to be_able_to(:view_share_work, FileSet) }
  end
end
