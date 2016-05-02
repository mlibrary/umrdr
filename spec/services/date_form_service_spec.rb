require 'rails_helper'

describe Umrdr::DateFormService do
  
  def self.test_for(date_coverage, expected)
     
      it "should parse into date fields" do
        expect((Umrdr::DateFormService.new(date_coverage)).parse).to eq(expected)
      end
    end
  context "when only from_date is entered" do
    test_for("2000-01-01", [2000,1,1])
    
  end

  context "when from_date and to_date range is entered" do
    test_for("2000-03-04/2001-02-02", [2000,3,4,2001,2,2])
  end
end