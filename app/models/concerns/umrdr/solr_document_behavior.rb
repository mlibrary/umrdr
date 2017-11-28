module Umrdr
  module SolrDocumentBehavior
    extend ActiveSupport::Concern

    # def creator
    #   descriptor = hydra_model.index_config[:creator].behaviors.first
    #   rv = fetch(Solrizer.solr_name('creator', descriptor), [])
    #   rv
    # end

    def methodology
      Array(self[Solrizer.solr_name('methodology')]).first
    end

    def date_coverage
      Array(self[Solrizer.solr_name('date_coverage')]).first
    end

    def isReferencedBy
      Array(self[Solrizer.solr_name('isReferencedBy')]).first
    end

    def authoremail
      Array(self[Solrizer.solr_name('authoremail')]).first
    end

    def fundedby
      Array(self[Solrizer.solr_name('fundedby')]).first
    end

    def grantnumber
      Array(self[Solrizer.solr_name('grantnumber')]).first
    end

    def tombstone
      Array(self[Solrizer.solr_name('tombstone')]).first
    end

    def file_size
      Array(self['file_size_lts']).first # standard lookup Solrizer.solr_name('file_size')] produces solr_document['file_size_tesim']
    end

    def file_size_readable
      ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert( file_size, precision: 3 )
    end

    def original_checksum
      Array(self[Solrizer.solr_name('original_checksum')]).first
    end

    def total_file_size
      Array(self['total_file_size_lts']).first # standard lookup Solrizer.solr_name('total_file_size')] produces solr_document['file_size_tesim']
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

  end
end
