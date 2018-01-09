require 'tasks/active_fedora_indexing_reindex_everything2'

class ResolrizeJob2 < ActiveJob::Base
  def perform
    ActiveFedora::Base.reindex_everything2( user_pacifier: false )
  end
end
