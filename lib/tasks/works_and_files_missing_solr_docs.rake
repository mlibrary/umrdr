require 'tasks/missing_solr_docs'

desc 'List works and their files missing solr docs'
task :works_and_files_missing_solr_docs => :environment do
  WorksAndFilesMissingSolrdocs.new().run
end

class WorksAndFilesMissingSolrdocs < MissingSolrdocs

  ## TODO
  def run
    @collections_missing_solr_docs = []
    @works_missing_solr_docs = []
    @work_id_to_missing_files_map = Hash.new()
    @orphan_file_ids = Hash.new()
    @works_missing_file_ids = Hash.new()
    @files_missing_solr_docs = []
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
            missing_files = find_missing_files_for_work( uri, id )
            @work_id_to_missing_files_map[id] = missing_files unless missing_files.empty?
            missing_files.each { |fid| @works_missing_file_ids[fid] = true }
          elsif file_set?( uri, id )
            @files_missing_solr_docs << id
            @orphan_file_ids[id] = true
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
    @works_missing_file_ids.keys.each { |fid| @orphan_file_ids.remove fid }
    puts "done"
    puts "count=#{count}"
    # report missing collections
    puts "collections_missing_solr_docs.count #{@collections_missing_solr_docs.count}"
    puts "collections_missing_solr_docs=#{@collections_missing_solr_docs}"
    # report missing works
    puts "works_missing_solr_docs.count #{@works_missing_solr_docs.count}"
    puts "works_missing_solr_docs=#{@works_missing_solr_docs}"
    # report missing files
    puts "@work_id_to_missing_files_map.count #{@work_id_to_missing_files_map.count}"
    puts "@work_id_to_missing_files_map=#{@work_id_to_missing_files_map.keys}"
    @work_id_to_missing_files_map.each_pair do |key,value|
      puts "work: #{key.id} has #{value.count} missing files"
      puts "work: #{key.id} file ids: #{value}"
    end
    # orphans
    puts "@orphan_file_ids.count #{@orphan_file_ids.count}"
    puts "@orphan_file_ids=#{@orphan_file_ids.keys}"
    # file ids missing solr docs
    puts "files_missing_solr_docs.count #{@files_missing_solr_docs.count}"
    puts "files_missing_solr_docs=#{@files_missing_solr_docs}" if @report_missing_files
    # other
    puts "other_missing_solr_docs.count #{@other_missing_solr_docs.count}"
    puts "other_missing_solr_docs=#{@other_missing_solr_docs.count}" if @report_missing_other
  end

end