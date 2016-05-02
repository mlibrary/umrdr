module Umrdr
  class DateFormService  

    attr_reader :date_range
    
    def initialize(date_range)
      @date_range = date_range
    end  

    def get_y_m_d(date_input)
      y_m_d = []

      if date_input && date_input.day_precision?
          y_m_d << date_input.year  
          y_m_d << date_input.month 
          y_m_d<< date_input.day 
        elsif date_input && date_input.month_precision?
          y_m_d << date_input.year  
          y_m_d << date_input.month 
          y_m_d << nil 
        elsif date_input && date_input.year_precision?
          y_m_d << date_input.year  
          y_m_d << nil
          y_m_d << nil  
        end
      return y_m_d
    end  

    def parse  
      if date_range.length>0
   
      	date_vals = []

          date_from_to = date_range.split('/')

          start_dt = EDTF.parse(date_from_to[0])
          end_dt =   EDTF.parse(date_from_to[1])
     
        date_vals = get_y_m_d(start_dt)
        date_vals = date_vals + get_y_m_d(end_dt) 

        return date_vals 
      end 
   
     return nil
    end	
  end
end