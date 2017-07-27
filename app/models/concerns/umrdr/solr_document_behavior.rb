module Umrdr
  module SolrDocumentBehavior
    extend ActiveSupport::Concern

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
  end

end
