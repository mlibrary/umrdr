# Additionally metadata
module Umrdr
  module CollectionMetadata
    extend ActiveSupport::Concern
    included do

      property :creator_ordered, predicate: ::RDF::Vocab::MODS.name, multiple: false do |index|
        index.type :text
        index.as :stored_searchable
      end

    end
  end
end