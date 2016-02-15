# Additionally metadata 
module Umrdr
  module GenericWorkMetadata
    extend ActiveSupport::Concern
    included do
      property :subject, predicate: ::RDF::Vocab::MODS.subject
    end
  end
end
