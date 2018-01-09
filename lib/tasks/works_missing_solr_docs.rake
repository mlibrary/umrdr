require 'tasks/missing_solr_docs'

desc 'List works missing solr docs'
task :works_missing_solr_docs => :environment do
  WorksMissingSolrdocs.new().run
end

class WorksMissingSolrdocs < MissingSolrdocs

  def run
    @collections_missing_solr_docs = []
    @files_missing_solr_docs = []
    @works_missing_solr_docs = []
    @other_missing_solr_docs = []
    @report_missing_files = false
    @report_missing_other = false
    @user_pacifier = false
    @verbose = false
    count = 0
    descendants = descendant_uris( ActiveFedora.fedora.base_uri,
                                   exclude_uri: true,
                                   user_pacifier: @user_pacifier )
    puts
    descendants.each do |uri|
      print "#{uri} ... " if @verbose
      id = uri_to_id( uri )
      puts "#{id}" if @verbose
      if filter_in( uri, id )
        doc = solr_doc( uri, id )
        hydra_model = hydra_model doc
        #puts "'#{hydra_model}'"
        #puts JSON.pretty_generate doc.as_json
        puts "generic_work? #{generic_work?( uri, id )}" if @verbose
        puts "file_set? #{file_set?( uri, id )}" if @verbose
        if doc.nil?
          if generic_work?( uri, id )
            @works_missing_solr_docs << id
          elsif file_set?( uri, id )
            @files_missing_solr_docs << id
          elsif collection?( uri, id )
            @collections_missing_solr_docs << id
          else
            @other_missing_solr_docs << id
          end
        elsif hydra_model == "GenericWork"
          count += 1
          puts "#{id}...good work" if @verbose
        elsif hydra_model == "FileSet"
          # skip
        elsif hydra_model == "Collection"
          puts "#{id}...good collection" if @verbose
        else
          puts "skipped '#{hydra_model}'"
          # skip
        end
      end
    end
    puts "done"
    puts "count=#{count}"
    puts "collections_missing_solr_docs.count #{@collections_missing_solr_docs.count}"
    puts "collections_missing_solr_docs=#{@collections_missing_solr_docs}"
    puts "works_missing_solr_docs.count #{@works_missing_solr_docs.count}"
    puts "works_missing_solr_docs=#{@works_missing_solr_docs}"
    puts "files_missing_solr_docs.count #{@files_missing_solr_docs.count}"
    puts "files_missing_solr_docs=#{@files_missing_solr_docs}" if @report_missing_files
    puts "other_missing_solr_docs.count #{@other_missing_solr_docs.count}"
    puts "other_missing_solr_docs=#{@other_missing_solr_docs.count}" if @report_missing_other
  end

end