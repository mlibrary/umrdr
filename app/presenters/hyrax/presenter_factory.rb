module Hyrax
  class PresenterFactory
    class << self
      # @param [Array] ids the list of ids to load
      # @param [Class] klass the class of presenter to make
      # @param [Array] args any other arguments to pass to the presenters
      # @return [Array] presenters for the documents in order of the ids
      def build_presenters(ids, klass, *args)
        new(ids, klass, *args).build
      end
    end

    attr_reader :ids, :klass, :args

    def initialize(ids, klass, *args)
      @ids = ids
      @klass = klass
      @args = args
    end

    def build
      return [] if ids.blank?
      docs = load_docs
      ids.map do |id|
        solr_doc = docs.find { |doc| doc.id == id }
        klass.new(solr_doc, *args) if solr_doc
      end.compact
    end

    private

      # Allow 10,000 files to be listed in item view.
      # @return [Array<SolrDocument>] a list of solr documents in no particular order
      def load_docs
        query("{!terms f=id}#{ids.join(',')}", rows: 10000)
          .map { |res| ::SolrDocument.new(res) }
      end

      # Query solr using POST so that the query doesn't get too large for a URI
      def query(query, args = {})
        args[:q] = query
        args[:qt] = 'standard'
        conn = ActiveFedora::SolrService.instance.conn
        result = conn.post('select', data: args)
        result.fetch('response').fetch('docs')
      end
  end
end
