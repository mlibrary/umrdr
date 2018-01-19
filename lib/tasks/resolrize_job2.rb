require 'tasks/active_fedora_indexing_reindex_everything2'
require 'tasks/task_logger'

class ResolrizeJob2 < ActiveJob::Base
  def perform
    logger = Umrdr::TaskLogger.new(STDOUT).tap { |logger| logger.level = Logger::INFO; Rails.logger = logger }
    ActiveFedora::Base.reindex_everything2( user_pacifier: false, logger: logger )
  end
end
