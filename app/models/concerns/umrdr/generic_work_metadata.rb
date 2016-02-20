# Additionally metadata 
module Umrdr
  module GenericWorkMetadata
    extend ActiveSupport::Concern
    included do
      property :subject, predicate: ::RDF::Vocab::MODS.subject
      property :doi, predicate: ::RDF::Vocab::Identifiers.doi
      property :hdl, predicate: ::RDF::Vocab::Identifiers.hdl
    end
  end
end
