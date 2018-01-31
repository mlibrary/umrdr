
desc 'Reindex works and their files with mismatching solr documents'
task :reindex_works_with_mismatching_solr_docs => :environment do
  ReindexWorksWithMismatchingSolrDocs.new().run
end

class ReindexWorksWithMismatchingSolrDocs

  def run
    @pacifier ||= Umrdr::TaskPacifier.new
    @logger ||= Umrdr::TaskLogger.new(STDOUT).tap { |logger| logger.level = Logger::INFO; Rails.logger = logger }
    @verify_report = true
    @verbose = true
    works_with = works_with_finder
    works_with.keys_to_skip.delete "system_modified_dtsi"
    works_with.report = true
    works_with.verbose = false
    works_with.run
    to_solr_failed = works_with.to_solr_failed
    works_with.files_mismatching_solr_docs.each { |id| reindex id unless to_solr_failed.include? id }
    works_with.works_mismatching_solr_docs.each { |id| reindex id unless to_solr_failed.include? id }
    if @verify_report
      works_with = works_with_finder
      works_with.report = true
      works_with.verbose = false
      works_with.run
    end
  end

  def reindex( id )
    @logger.info "reindex #{id}" if @verbose
    batch = []
    begin
      obj = ActiveFedora::Base.find(id)
      batch << obj.to_solr
    rescue Exception => e
      @pacifier.pacify '<!b>' unless @pacifier.nil?
      @logger.error "#{id} - #{e.class}: #{e.message} at #{e.backtrace[0]}" unless @logger.nil?
      return
    end
    begin
      @pacifier.pacify 's' unless @pacifier.nil?
      SolrService.add( batch, softCommit: true )
    rescue Exception => e
      @pacifier.pacify '<!s>' unless @pacifier.nil?
      @logger.error "#{id} -- #{e.class}: #{e.message} at #{e.backtrace[0]}" unless @logger.nil?
    end
  end

  def works_with_finder
    works_with = WorksWithMismatchingSolrDocs.new().tap do |ww|
      ww.pacifier = @pacifier
      ww.logger = @logger
    end
    return works_with
  end

end
