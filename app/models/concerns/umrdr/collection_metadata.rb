# Additionally metadata
module Umrdr
  module CollectionMetadata
    extend ActiveSupport::Concern
    included do
      #
      # property :creator_ordered, predicate: ::RDF::Vocab::MODS.name, multiple: false do |index|
      #   index.type :text
      #   index.as :stored_searchable
      # end
      #
      # property :description_ordered, predicate: ::RDF::URI.new('https://deepblue.lib.umich.edu/data/help.help#description_ordered'), multiple: false do |index|
      #   index.type :text
      #   index.as :stored_searchable
      # end
      #
      # property :isReferencedBy, predicate: ::RDF::Vocab::DC.isReferencedBy, multiple: true do |index|
      #   index.type :text
      #   index.as :stored_searchable
      # end
      #
      # property :keyword_ordered, predicate: ::RDF::URI.new('https://deepblue.lib.umich.edu/data/help.help#keyword_ordered'), multiple: false do |index|
      #   index.type :text
      #   index.as :stored_searchable
      # end
      #
      # property :language_ordered, predicate: ::RDF::URI.new('https://deepblue.lib.umich.edu/data/help.help#language_ordered'), multiple: false do |index|
      #   index.type :text
      #   index.as :stored_searchable
      # end
      #
      # property :title_ordered, predicate: ::RDF::URI.new('https://deepblue.lib.umich.edu/data/help.help#title_ordered'), multiple: false do |index|
      #   index.type :text
      #   index.as :stored_searchable
      # end

    end
  end
end