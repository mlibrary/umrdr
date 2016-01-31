class GenericWork < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  include Sufia::WorkBehavior
  include Umrdr::GenericWorkBehavior
  validates :title, presence: { message: 'Your work must have a title.' }
end
