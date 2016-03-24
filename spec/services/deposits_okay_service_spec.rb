require 'rails_helper'

describe Umrdr::DepositsOkayService do
  okay = double(Umrdr::DepositsOkayService)

  it "can not find a uniqname known to have no entry" do
    allow(okay).to receive(new("zzzzzz")).and_return(false)
    expect(okay.deposit_okay_for("zzzzzz")).to be_falsey
  end

  it "can return true when checking status of a known staff or faculty member" do
    allow(okay).to receive(new("jweise")).and_return(true)
    expect(okay.new("jweise")).to be_truthy
  end
end