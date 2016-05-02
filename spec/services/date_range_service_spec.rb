require 'rails_helper'

describe Umrdr::DateRangeService do

  context "when from date is entered" do
    def self.test_for(params = {}, expected)
  	  default_params = {:date_coverage_1_year => "", :date_coverage_1_month => "--", :date_coverage_1_day => '--', :date_coverage_2_year => "", :date_coverage_2_month =>"--", :date_coverage_2_day => "--" }
  	  actual_params = default_params.merge(params)
      it "should convert #{actual_params.inspect} to #{expected.inspect}" do
        expect((Umrdr::DateRangeService.new(actual_params)).transform_dt1).to eq(expected)
      end
    end

    test_for({:date_coverage_1_year=>"2000"}, "2000-01-01")
    test_for({:date_coverage_1_year=>"2000", :date_coverage_1_month=>"02" }, "2000-02-01")
    test_for({:date_coverage_1_year=>"2000", :date_coverage_1_month=>"02" , :date_coverage_1_day=>"2" }, "2000-02-02")
  end

  context "when to date is entered" do
    def self.test_for(params = {}, expected)
  	  default_params = {:date_coverage_1_year => "", :date_coverage_1_month => "--", :date_coverage_1_day => '--', :date_coverage_2_year => "", :date_coverage_2_month =>"--", :date_coverage_2_day => "--" }
  	  actual_params = default_params.merge(params)
      it "should convert #{actual_params.inspect} to #{expected.inspect}" do
        expect((Umrdr::DateRangeService.new(actual_params)).transform_dt2).to eq(expected)
      end
    end

    test_for({:date_coverage_2_year=>"2000"}, "2000-01-01")
    test_for({:date_coverage_2_year=>"2000", :date_coverage_2_month=>"02" }, "2000-02-01")
    test_for({:date_coverage_2_year=>"2000", :date_coverage_2_month=>"02" , :date_coverage_2_day=>"2" }, "2000-02-02")
  end
end
