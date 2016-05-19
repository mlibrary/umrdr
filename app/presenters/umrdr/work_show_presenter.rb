
module Umrdr
  class WorkShowPresenter < ::Sufia::WorkShowPresenter

    attr_accessor :object_profile
    delegate :methodology, :date_coverage, to: :solr_document

    def initialize(solr_document, current_ability)
      super
      @object_profile = JSON.parse(solr_document['object_profile_ssm'].first || "{}", symbolize_names: true)
    end

    # display date range as from_date To to_date
    def date_coverage
      date_interval = @object_profile[:date_coverage].first
    
      if date_interval && date_interval.index('/') == date_interval.length-1
        date_interval = date_interval[0..date_interval.length-2]
      elsif date_interval
        date_interval.sub! "/", " To "  
      end  
      
      return date_interval
    end
      
    def doi
      @object_profile[:doi]
    end

    def hdl
      @object_profile[:hdl]
    end

    def identifiers_minted?(identifier)
      return @object_profile[identifier]
    end

    def identifiers_pending?(identifier)
      @object_profile[identifier] == GenericWork::PENDING
    end

  end
end
