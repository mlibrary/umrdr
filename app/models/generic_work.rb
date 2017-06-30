class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::Hyrax::BasicMetadata
  #include Sufia::WorkBehavior
  self.human_readable_type = 'Generic Work'
  include Umrdr::GenericWorkBehavior
  include Umrdr::GenericWorkMetadata
  validates :title, presence: { message: 'Your work must have a title.' }
  validates :creator, presence: { message: 'Your work must have a creator.' }
  validates :description, presence: { message: 'Your work must have a description.' }
  validates :methodology, presence: { message: 'Your work must have a description of the method for collecting the dataset.' }
  validates :rights, presence: { message: 'You must select a license for your work.' }
  validates :authoremail, presence: { message: 'You must have author contact information.' }

  after_initialize :set_defaults

  PENDING = 'pending'.freeze

  def set_defaults
    return unless new_record?
    self.resource_type = ["Dataset"]
  end

  # Visibility helpers
  def private?
    visibility == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
  end

  def public?
    visibility == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  end
end
