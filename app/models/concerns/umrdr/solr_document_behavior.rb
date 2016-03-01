module Umrdr
  module SolrDocumentBehavior
    extend ActiveSupport::Concern

    def methodology
      Array(self[Solrizer.solr_name('methodology')]).first
    end

  end

end