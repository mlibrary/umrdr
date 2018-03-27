
include MetadataHelper

class Collection < ActiveFedora::Base
  include ::Hyrax::CollectionBehavior
  # You can replace these metadata if they're not suitable
  include Hyrax::BasicMetadata
  include Umrdr::GenericWorkMetadata

  after_initialize :set_defaults
  
  # property :isReferencedBy, predicate: ::RDF::Vocab::DC.isReferencedBy, multiple: true do |index|
  #  index.type :text
  #  index.as :stored_searchable
  # end

  #
  # handle the list of creator as ordered
  #
  def creator
    values = super
    values = MetadataHelper.ordered( ordered_values: self.creator_ordered, values: values )
    return values
  end

  def creator= values
    self.creator_ordered = MetadataHelper.ordered_values( ordered_values: self.creator_ordered, values: values )
    super values
  end

  #
  # handle the list of description as ordered
  #
  def description
    values = super
    values = MetadataHelper.ordered( ordered_values: self.description_ordered, values: values )
    return values
  end

  def description= values
    self.description_ordered = MetadataHelper.ordered_values( ordered_values: self.description_ordered, values: values )
    super values
  end

  #
  # handle the list of isReferencedBy as ordered
  #
  def isReferencedBy
    values = super
    values = MetadataHelper.ordered( ordered_values: self.isReferencedBy_ordered, values: values )
    return values
  end

  def isReferencedBy= values
    self.isReferencedBy_ordered = MetadataHelper.ordered_values( ordered_values: self.isReferencedBy_ordered, values: values )
    super values
  end

  #
  # handle the list of keyword as ordered
  #
  def keyword
    values = super
    values = MetadataHelper.ordered( ordered_values: self.keyword_ordered, values: values )
    return values
  end

  def keyword= values
    self.keyword_ordered = MetadataHelper.ordered_values( ordered_values: self.keyword_ordered, values: values )
    super values
  end

  #
  # handle the list of language as ordered
  #
  def language
    values = super
    values = MetadataHelper.ordered( ordered_values: self.language_ordered, values: values )
    return values
  end

  def language= values
    self.language_ordered = MetadataHelper.ordered_values( ordered_values: self.language_ordered, values: values )
    super values
  end

  def set_defaults
    return unless new_record?
    self.visibility = 'open'
  end

  #
  # handle the list of title as ordered
  #
  def title
    values = super
    values = MetadataHelper.ordered( ordered_values: self.title_ordered, values: values )
    return values
  end

  def title= values
    self.title_ordered = MetadataHelper.ordered_values( ordered_values: self.title_ordered, values: values )
    super values
  end

end 
