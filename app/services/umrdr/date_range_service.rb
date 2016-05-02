module Umrdr
  class DateRangeService  

    attr_reader :params
    
    def initialize(params)
      @params = params
    end  

    def parse
byebug
      st = EDTF.parse(params['generic_work']['date_coverage'])
      start_dt = st.day
      start_mon = st.mon
      start_yr = st.year    

      #end_dt = EDTF.parse(params[:date_coverage_start])
      result =  {'yr'=>start_yr,'mon'=>start_mon,'dt'=>start_dt}
      return  result
    end  

    def transform

    if (params[:date_coverage_1_year].length>0)
      yyyy1= params[:date_coverage_1_year].to_i 
    else
      yyyy2 = 0 #error 
    end  
    if (!params[:date_coverage_1_month].eql?("--"))
      mm1 =  params[:date_coverage_1_month].to_i   
    else
      mm1 = 1    
    end

    if (!params[:date_coverage_1_day].eql?("--"))
      dd1 = params[:date_coverage_1_day].to_i
    else
      dd1 = 1  
    end

    if (params[:date_coverage_2_year].length>0)
      yyyy2 = params[:date_coverage_2_year].to_i
    else
      yyyy2 = 0  #error 
    end
    if (!params[:date_coverage_2_month].eql? "--")
      mm2 = params[:date_coverage_2_month].to_i
    else
      mm2 =  1  
    end

    if (!params[:date_coverage_2_day].eql? "--")
       dd2 = params[:date_coverage_2_day].to_i
    else
       dd2 = 1
    end
   
    if  (yyyy1 >0)
      dateC = Date.new(yyyy1,mm1,dd1).edtf 
    end
    if (yyyy2 >0)
      dateC = dateC + " TO " +  Date.new(yyyy2,mm2,dd2).edtf 
    end
   
    return dateC
   end
  end
end  