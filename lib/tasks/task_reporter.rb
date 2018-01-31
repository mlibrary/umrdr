
module TaskReporter

  attr_accesor :log, :pacifier

  def log
    @log ||= initialize_log
  end

  def pacifier
    @pacifier ||= initialize_pacifier
  end

  protected

  def initialize_log
    Umrdr::TaskLogger.new(STDOUT).tap { |logger| logger.level = Logger::INFO; Rails.logger = logger }
  end

  def initialize_pacifier
    Umrdr::TaskPacifier.new( out: STDOUT )
  end

end