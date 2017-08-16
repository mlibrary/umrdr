# Additionally metadata 
module Umrdr
  module GenericWorkMetadata
    extend ActiveSupport::Concern
    included do
      property :subject, predicate: ::RDF::Vocab::MODS.subject
      property :date_coverage, predicate: ::RDF::Vocab::DC.temporal, multiple: true do |index| 
       index.type :text 
       index.as :stored_searchable, :facetable
      end
      property :doi, predicate: ::RDF::Vocab::Identifiers.doi, multiple: false

      property :hdl, predicate: ::RDF::Vocab::Identifiers.hdl, multiple: false

      property :methodology, predicate: ::RDF::URI.new('http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/datacollection_xsd/elements/DataCollectionMethodology.html'), multiple: false do |index|
        index.type :text
        index.as :stored_searchable
      end
      property :isReferencedBy, predicate: ::RDF::Vocab::DC.isReferencedBy, multiple: true do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :authoremail, predicate: ::RDF::Vocab::FOAF.mbox, multiple: false do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :fundedby, predicate: ::RDF::Vocab::DISCO.fundedBy, multiple: true do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :grantnumber, predicate: ::RDF::URI.new('http://purl.org/cerif/frapo/hasGrantNumber'), multiple: false do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :tombstone, predicate: ::RDF::Vocab::DC.provenance
    end
  end
end
