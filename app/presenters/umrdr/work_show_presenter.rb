
module Umrdr
  class WorkShowPresenter < ::Sufia::WorkShowPresenter

    attr_accessor :object_profile

    delegate :methodology, :date_coverage, :isReferencedBy, :authoremail, :fundedby, :grantnumber, to: :solr_document

    def initialize(solr_document, current_ability, request = nil)
     super
    #  @object_profile = JSON.parse(solr_document['object_profile_ssm'].first || "{}", symbolize_names: true)
    end

    # display date range as from_date To to_date
    def date_coverage
      @solr_document.date_coverage.sub("/", " to ") if @solr_document.date_coverage
    end

    def isReferencedBy
      @solr_document.isReferencedBy
    end  

    def authoremail
      @solr_document.authoremail
    end

    def fundedby
      @solr_document.fundedby
    end

    def grantnumber
      @solr_document.grantnumber
    end
      
    def doi
      @solr_document.doi
    end

    def hdl
      @object_profile[:hdl]
    end

    def identifiers_minted?(identifier)
      return @solr_document[identifier]

    end

    def identifiers_pending?(identifier)
      @object_profile[identifier] == GenericWork::PENDING
    end

  end
end
