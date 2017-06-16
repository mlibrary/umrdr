# Generated by curation_concerns:models:install
class FileSet < ActiveFedora::Base
  include ::Hyrax::FileSetBehavior
  include Umrdr::FileSetBehavior

  after_initialize :set_defaults

  def set_defaults
    return unless new_record?
    self.visibility = 'open'
  end
end
