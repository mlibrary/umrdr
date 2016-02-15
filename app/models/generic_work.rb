class GenericWork < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  include Sufia::WorkBehavior
  include Umrdr::GenericWorkBehavior
  include Umrdr::GenericWorkMetadata
  validates :title, presence: { message: 'Your work must have a title.' }
  validates :creator, presence: { message: 'Your work must have a creator.' }
  validates :date_created, presence: { message: 'Your work must have a date created.' }
  validates :description, presence: { message: 'Your work must have a description.' }

  after_initialize :set_defaults

  def set_defaults
    return unless new_record?
    self.resource_type = ['Dataset']
    self.visibility = 'open'
  end
end
