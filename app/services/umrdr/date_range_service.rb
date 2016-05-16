module Umrdr
  class DateRangeService  

    attr_reader :params
    
    def initialize(params)
      @params = params
    end  

    def get_yr_mon_day(date_param)
      if params[date_param].length>0 && params[date_param].match(/^\d+$/)
        val = params[date_param].to_i
      else
        val = nil 
      end
      return val
    end  

    def get_precision_date(y,m,d)
      args = []

      if y 
        args << y
        precision = :"year_precision!"
      if m 
        args << m
        precision = :"month_precision!"
       if d
        args << d
        precision = :"day_precision!"
       end
      end
     end 

      if y 
        val = Date.new(*args)
        val.send(precision)
      #  val = val.edtf
      else
        val = nil
      end
        
      return val
    end  

    def transform

      y = get_yr_mon_day(:date_coverage_begin_year)
      m = get_yr_mon_day(:date_coverage_begin_month)
      d = get_yr_mon_day(:date_coverage_begin_day)

      date_from = get_precision_date(y,m,d)
      
      y = get_yr_mon_day(:date_coverage_end_year)
      m = get_yr_mon_day(:date_coverage_end_month)
      d = get_yr_mon_day(:date_coverage_end_day)

      date_to = get_precision_date(y,m,d)
      
    
      date_interval = EDTF::Interval.new(date_from,date_to)    
    
    if date_interval.to || date_interval.from 
     return date_interval.to_s
    end
    return nil

   end
  end 
end
 
