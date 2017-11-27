
module Umrdr
  class WorkShowPresenter < ::Hyrax::WorkShowPresenter

    delegate :methodology, :date_coverage, :isReferencedBy, :authoremail, :fundedby, :grantnumber, :doi,
             :tombstone, :total_file_size,
             to: :solr_document

    def authoremail
      @solr_document.authoremail
    end

    # display date range as from_date To to_date
    def date_coverage
      @solr_document.date_coverage.sub("/", " to ") if @solr_document.date_coverage
    end

    def doi
      @solr_document[Solrizer.solr_name('doi', :symbol)].first
    end

    def fundedby
      @solr_document.fundedby
    end

    def globus_external_url
      concern_id = @solr_document.id
      ::GlobusJob.external_url concern_id
    end

    def globus_files_available?
      concern_id = @solr_document.id
      ::GlobusJob.files_available? concern_id
    end

    def grantnumber
      @solr_document.grantnumber
    end

    def hdl
      #@object_profile[:hdl]
    end

    def human_readable( value )
      ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert( value, precision: 3 )
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

    def isReferencedBy
      @solr_document.isReferencedBy
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
      human_readable( total_file_size )
    end

  end
end
