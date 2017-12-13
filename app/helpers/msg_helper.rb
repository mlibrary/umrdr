module MsgHelper

  @@FIELD_SEP = '; '.freeze

  def self.creator( curration_concern )
    curration_concern.creator.join( @@FIELD_SEP )
  end

  def self.globus_link( curration_concern )
    ::GlobusJob.external_url curration_concern.id
  end

  def self.title( curration_concern )
    curration_concern.title.join( @@FIELD_SEP )
  end

  def self.work_location( curration_concern )
    Rails.application.routes.url_helpers.hyrax_generic_work_url( id: curration_concern.id )
  end

end