module Umrdr
  module SolrDocumentBehavior
    extend ActiveSupport::Concern

    def methodology
      Array(self[Solrizer.solr_name('methodology')]).first
    end

    def date_coverage_from
      Array(self[Solrizer.solr_name('date_coverage_from')]).first
    end

     def date_coverage_to
      Array(self[Solrizer.solr_name('date_coverage_to')]).first
    end
  end

end
