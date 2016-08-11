class GenericWork < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  include Sufia::WorkBehavior
  include Umrdr::GenericWorkBehavior
  include Umrdr::GenericWorkMetadata
  validates :title, presence: { message: 'Your work must have a title.' }
  validates :creator, presence: { message: 'Your work must have a creator.' }
  validates :description, presence: { message: 'Your work must have a description.' }
  validates :methodology, presence: { message: 'Your work must have a description of the method for collecting the dataset.' }
  validates :rights, presence: { message: 'You must select a license for your work.' }

  after_initialize :set_defaults

  PENDING = 'pending'.freeze

  def set_defaults
    return unless new_record?
    self.resource_type = ['Dataset']
  end
end
