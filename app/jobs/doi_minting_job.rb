class DOIMintingJob < ActiveFedoraIdBasedJob
  queue_as :handle
  def perform(id)
    @id = id

    work = object

    # Don't mint a handle if already has one
    return if work.hdl
  end

  private
end
