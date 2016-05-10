# Additionally metadata 
module Umrdr
  module GenericWorkMetadata
    extend ActiveSupport::Concern
    included do
      property :subject, predicate: ::RDF::Vocab::MODS.subject
      property :date_coverage, predicate: ::RDF::Vocab::DC.temporal, multiple: false do |index| 
       index.type :text 
       index.as :stored_searchable, :facetable
      end
      property :doi, predicate: ::RDF::Vocab::Identifiers.doi, multiple: false
      property :hdl, predicate: ::RDF::Vocab::Identifiers.hdl, multiple: false
      property :methodology, predicate: ::RDF::URI.new('http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/datacollection_xsd/elements/DataCollectionMethodology.html'), multiple: false do |index|
        index.type :text
        index.as :stored_searchable
      end
    end
  end
end
