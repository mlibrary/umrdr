require 'rails_helper'

describe Umrdr::DateRangeService do

  def self.test_for(params = {}, expected)
      default_params = {:date_coverage_1_year => "", :date_coverage_1_month => "--", :date_coverage_1_day => '--', :date_coverage_2_year => "", :date_coverage_2_month =>"--", :date_coverage_2_day => "--" }
      actual_params = default_params.merge(params)
      it "should convert #{actual_params.inspect} to #{expected.inspect}" do
        expect((Umrdr::DateRangeService.new(actual_params)).transform).to eq(expected)
      end
  end

  context "when only from_date is entered" do

    test_for({:date_coverage_1_year=>"2000"}, "2000/")
    test_for({:date_coverage_1_year=>"2000", :date_coverage_1_month=>"02" }, "2000-02/")
    test_for({:date_coverage_1_year=>"2000", :date_coverage_1_month=>"02" , :date_coverage_1_day=>"2" }, "2000-02-02/")
  end

  context "when only  to_date is entered" do

    test_for({:date_coverage_2_year=>"2000"}, "/2000")
    test_for({:date_coverage_2_year=>"2000", :date_coverage_2_month=>"02" }, "/2000-02")
    test_for({:date_coverage_2_year=>"2000", :date_coverage_2_month=>"02" , :date_coverage_2_day=>"2" }, "/2000-02-02")
  end

  context "when from_date and to_date range is entered" do
    
    test_for({:date_coverage_1_year=>"2000", :date_coverage_1_month=>"2" , :date_coverage_1_day=>"2" ,:date_coverage_2_year=>"2001", :date_coverage_2_month=>"2" , :date_coverage_2_day=>"2" }, "2000-02-02/2001-02-02")
  end
end
