require 'spec_helper'
require 'pry'
require_relative '../../app/services/umrdr/date_coverage_service'

# TODO: Extract converts params to interval and converts interval to parameters as RSpec shared examples.
# TODO: Add idempotent conversion check to shared examples params -> interval -> params in a single go.

# Helper method for making a date coverage hash that matches the keys passed by the parameters of the input/edit form
def make_params( begin_year=nil, begin_month=nil, begin_day=nil, end_year=nil, end_month=nil, end_day=nil)
  {date_coverage_begin_year:  begin_year,
   date_coverage_begin_month: begin_month,
   date_coverage_begin_day:   begin_day, 
   date_coverage_end_year:    end_year,
   date_coverage_end_month:   end_month,
   date_coverage_end_day:     end_day} 
end

describe Umrdr::DateCoverageService do
  describe 'handling of begin date only' do
    let(:begin_params) { make_params('2016','2','10',nil,nil,nil) }
    let(:begin_interv) { EDTF::Interval.new(EDTF.parse('2016-02-10'), :open) }

    it 'converts parameters to an interval' do
      expect( described_class.params_to_interval(begin_params) ).to eq(begin_interv)
    end

    it 'coverts an interval to parameters' do
      expect( described_class.interval_to_params(begin_interv) ).to eq(begin_params)
    end
  end

  describe 'handling of end date only' do
    let(:end_params) { make_params(nil,nil,nil,'2016','2','10') }
    let(:end_interv) { EDTF::Interval.new(:unknown, EDTF.parse('2016-02-10')) }

    # Comparision with open begin is borked upstream.  See https://github.com/inukshuk/edtf-ruby/issues/18
    # Do full circle conversion instead.
    it 'converts parameters to an interval' do
      expect( described_class.params_to_interval(end_params) ).to eq(end_interv)
    end

    it 'coverts an interval to parameters' do
      expect( described_class.interval_to_params(end_interv) ).to eq(end_params)
    end
  end

  describe 'handling of begin and end dates' do
    let(:params) { make_params('2010','3','2','2016','4','21') }
    let(:interv) { EDTF::Interval.new(EDTF.parse('2010-03-02'), EDTF.parse('2016-04-21')) }

    it 'converts parameters to an interval' do
      expect( described_class.params_to_interval(params) ).to eq(interv)
    end

    it 'coverts an interval to parameters' do
      expect( described_class.interval_to_params(interv) ).to eq(params)
    end
  end

  # Case where start date entered is after the end date entered
  describe 'handling of begin and end dates in reverse order' do
    let(:backwards_params) { make_params('2014','5','16','2010','11','22') }
    let(:backwards_interv) { EDTF::Interval.new(EDTF.parse('2014-05-16'), EDTF.parse('2010-11-22')) }

    it 'does not generate an interval from parameters' do
      expect( described_class.params_to_interval(backwards_params) ).to be_nil
    end

    it 'does not generate parameters from a backwards interval' do
      expect( described_class.interval_to_params(backwards_interv) ).to be_nil
    end
  end

  describe 'handling of partial dates' do
    describe 'less than three digit years' do
      let(:yr10_params) { make_params('0010',nil,nil,'0020','12',nil) }
      let(:yr800_params) { make_params('0800','11','10','0900','12','6') }
      let(:yr10_interv) { EDTF::Interval.new(EDTF.parse('0010'), EDTF.parse('0020-12')) }
      let(:yr800_interv) { EDTF::Interval.new(EDTF.parse('0800-11-10'), EDTF.parse('0900-12-06')) }

      it 'converts parameters to an interval' do
        expect( described_class.params_to_interval(yr10_params) ).to eq(yr10_interv)
        expect( described_class.params_to_interval(yr800_params) ).to eq(yr800_interv)
      end

      it 'coverts an interval to parameters' do
        expect( described_class.interval_to_params(yr10_interv) ).to eq(yr10_params)
        expect( described_class.interval_to_params(yr800_interv) ).to eq(yr800_params)
      end
    end

    describe 'month precision dates' do
      let(:params) { make_params('2010','11',nil,'2016','12',nil) }
      let(:interv) { EDTF::Interval.new(EDTF.parse('2010-11'), EDTF.parse('2016-12')) }

      it 'converts params to an interval with month precision' do
        resulting_interval = described_class.params_to_interval(params) 
        expect(resulting_interval).to eq(interv)
        expect(resulting_interval.precision).to eq(:month)
      end

      it 'converts interval to parameters with year and day only' do
        expect( described_class.interval_to_params(interv) ).to eq(params)
      end
    end

    describe 'dates with year precision' do
      let(:params) { make_params('2010',nil,nil,'2016',nil,nil) }
      let(:interv) { EDTF::Interval.new(EDTF.parse('2010'), EDTF.parse('2016')) }

      it 'converts params to an interval with year precision' do
        resulting_interval = described_class.params_to_interval(params) 
        expect(resulting_interval).to eq(interv)
        expect(resulting_interval.precision).to eq(:year)
      end

      it 'converts interval to parameters with year only' do
        expect( described_class.interval_to_params(interv) ).to eq(params)
      end

    end

    describe 'dates with missing month parameter' do
      let(:params) { make_params('2010',nil,'17','2016',nil,'18') }
      let(:interv) { EDTF::Interval.new(EDTF.parse('2010'), EDTF.parse('2016')) }

      it 'converts params to an interval with year precision' do
        resulting_interval = described_class.params_to_interval(params) 
        expect(resulting_interval).to eq(interv)
        expect(resulting_interval.precision).to eq(:year)
      end
    end
  end

  describe 'handling negative dates' do
    let(:params) { make_params('-5000','10','5','-2345','9','13') }
    let(:interv) { EDTF::Interval.new(EDTF.parse('-5000-10-05'), EDTF.parse('-2345-09-13')) }

    it 'converts parameters to an interval' do
      expect( described_class.params_to_interval(params) ).to eq(interv)
    end

    it 'converts interval to parameters' do
      expect( described_class.interval_to_params(interv) ).to eq(params)
    end

    it 'converts years with fewer than 3 digits' do
      skip 'upstream issue https://github.com/inukshuk/edtf-ruby/issues/20 (but what is the test??)'
    end
  end

  describe 'handling of no dates' do
    let(:empty_params) { make_params("","--","--","","--","--") }

    it 'returns nil given nil' do
      result = described_class.params_to_interval(empty_params)
      expect(result).to be_nil
    end
  end
end
                            
