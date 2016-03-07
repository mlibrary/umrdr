require 'rails_helper'

RSpec.describe WorkMailer, type: :mailer do
  let(:from) { 'me@example.com' }
  let(:body) { 'Deposit message' }
  let(:subj) { 'New Deposit' }
 
  describe '#deposit_work' do
    before do
      email
    end

    describe 'can send email' do
      subject(:email) do
        msg = WorkMailer.deposit_work(from, body)
        msg.deliver_now
      end

      it 'sends an email with link to new work' do
        expect(ActionMailer::Base.deliveries).to_not be_empty
        expect(email.from).to eq Array(from)
        expect(email.body.to_s).to eq body
      end
    end
  end
end
