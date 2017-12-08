
include OrderedStringHelper

class Collection < ActiveFedora::Base                            
  include ::Hyrax::CollectionBehavior
  # You can replace these metadata if they're not suitable
  include Hyrax::BasicMetadata
  include Umrdr::GenericWorkMetadata

  after_initialize :set_defaults
  
  property :isReferencedBy, predicate: ::RDF::Vocab::DC.isReferencedBy, multiple: true do |index|
   index.type :text
   index.as :stored_searchable
  end

  #
  # handle the list of creators as ordered
  #
  def creator
    values = super
    if Umrdr::Application.config.creator_ordered_list_hack
      # check for existence of creator_ordered and override values it isn't null
      ordered = self.creator_ordered
      values = OrderedStringHelper.deserialize( ordered ) unless ordered.nil?
    end
    values
  end

  def creator= values
    if Umrdr::Application.config.creator_ordered_list_hack
      if Umrdr::Application.config.creator_ordered_list_hack_save
        self.creator_ordered = OrderedStringHelper.serialize( values )
      elsif !self.creator_ordered.nil?
        self.creator_ordered = OrderedStringHelper.serialize( values )
      end
    end
    super values
  end

  def set_defaults
    return unless new_record?
    self.visibility = 'open'
  end

end 
