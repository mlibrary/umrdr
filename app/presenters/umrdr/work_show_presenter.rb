
module Umrdr
  class WorkShowPresenter < ::Hyrax::WorkShowPresenter

    delegate :methodology, :date_coverage, :isReferencedBy, :authoremail, :fundedby, :grantnumber, :doi,
             :tombstone, :total_file_size,
             to: :solr_document

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
      @solr_document[Solrizer.solr_name('doi', :symbol)].first
    end

    def tombstone
      if @solr_document[Solrizer.solr_name('tombstone', :symbol)].nil?
        nil
      else
        @solr_document[Solrizer.solr_name('tombstone', :symbol)].first
      end
    end

    def total_file_count
      if @solr_document[Solrizer.solr_name('file_set_ids', :symbol)].nil?
        0
      else
        @solr_document[Solrizer.solr_name('file_set_ids', :symbol)].size
      end
    end

    def total_file_size
      total = @solr_document[Solrizer.solr_name('total_file_size', Hyrax::FileSetIndexer::STORED_LONG)]
      if total.nil?
        total = 0
      end
      total
    end

    def total_file_size_human_readable
    #   if @solr_document[Solrizer.solr_name('total_file_size_human_readable', :symbol)].nil?
    #     nil
    #   else
    #     @solr_document[Solrizer.solr_name('total_file_size_human_readable', :symbol)].first
    #   end
      total = total_file_size
      ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert( total, precision: 3 )
    end

    def hdl
      #@object_profile[:hdl]
    end

    def identifiers_minted?(identifier)
      #the first time this is called, doi will not be solr.
      begin
        @solr_document[Solrizer.solr_name('doi', :symbol)].first
      rescue
        nil
      end
    end

    def identifiers_pending?(identifier)
      @solr_document[Solrizer.solr_name('doi', :symbol)].first == GenericWork::PENDING
    end

  end
end
