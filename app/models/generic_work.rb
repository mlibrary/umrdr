
include OrderedStringHelper

class GenericWork < ActiveFedora::Base
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

  #
  # handle the list of creators as ordered
  #
  # def creator
  #   values = super
  #   if Umrdr::Application.config.creator_ordered_list_hack
  #     # check for existence of creator_ordered and override values it isn't null
  #     ordered = self.creator_ordered
  #     values = OrderedStringHelper.deserialize( ordered ) unless ordered.nil?
  #   end
  #   values
  # end
  # 
  # def creator= values
  #   if Umrdr::Application.config.creator_ordered_list_hack
  #     if Umrdr::Application.config.creator_ordered_list_hack_save
  #       self.creator_ordered = OrderedStringHelper.serialize( values )
  #     elsif !self.creator_ordered.nil?
  #       self.creator_ordered = OrderedStringHelper.serialize( values )
  #     end
  #   end
  #   super values
  # end
  include ::Hyrax::WorkBehavior
  include ::Hyrax::BasicMetadata
end
