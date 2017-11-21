#
# TODO: visit and figure out what is useful and what needs to be changed or deleted.
#

require 'oga'

require_dependency 'libraoc/helpers/service_helpers'
include Helpers

module TaskHelpers

  # used for the extract/ingest processing
  INGEST_ID_FILE ||= 'ingest.id'
  DOCUMENT_FILES_LIST ||= 'filelist.txt'
  DOCUMENT_JSON_FILE ||= 'data.json'
  DOCUMENT_XML_FILE ||= 'data.xml'

  # general definitions
  DEFAULT_USER ||= 'dpg3k'
  DEFAULT_DOMAIN ||= 'virginia.edu'

  #
  # disable the callbacks that are used for workflow; this ensures that we control sgtate changes, etc better
  # during ingest, and various other
  #
  def disable_workflow_callbacks

    # disable the allocate DOI callback
    LibraWork.skip_callback( :save, :after, :allocate_doi )

    # disable the email send callback
    LibraWork.skip_callback( :save, :after, :determine_email_behavior )

  end

  #
  # the default user for various admin activities
  #
  def default_user_email
    return default_email( DEFAULT_USER )
  end

  #
  # construct a default email address given a computing Id
  #
  def default_email( cid )
    return "#{cid}@#{DEFAULT_DOMAIN}"
  end

  #
  # get a work by the specified ID
  #
  def get_work_by_id( work_id )

    begin
      return LibraWork.find( work_id )
    rescue => e
    end

    return nil
  end

  #
  # download a random cat image
  #
  def get_random_image( )

    print "getting image... "

    dest_file = "#{File::SEPARATOR}tmp#{File::SEPARATOR}#{SecureRandom.hex( 5 )}.jpg"
    Net::HTTP.start( "lorempixel.com" ) do |http|
      resp = http.get("/640/480/cats/")
      open( dest_file, "wb" ) do |file|
        file.write( resp.body )
      end
    end
    puts "done"
    return dest_file

  end

  #
  # get user information from an email address
  #
  def user_info_by_email( email )
    id = User.cid_from_email( email )
    return user_info_by_cid( id )
  end

  #
  # get user information from a computing id
  #
  def user_info_by_cid( id )

    print "Looking up user details for #{id}..."

    # lookup the user by computing id
    user_info = Helpers.lookup_user( id )
    if user_info.nil?
      puts "not found"
      return nil
    end

    puts "done"
    return user_info
  end

  #
  # lookup a user by computing id and create their account if we locate them
  #
  def lookup_and_create_account( id )

    # lookup locally with the default email
    user = User.find_by_email( User.email_from_cid( id ) )
    return user if user.present?

    # if we cannot find them, lookup in LDAP
    user_info = user_info_by_cid( id )
    return nil if user_info.nil?

    # now look them up with the located email
    user = User.find_by_email( user_info.email )
    return user if user.present?

    # create their account
    return User.new_user( user_info, user_info.email )
  end

  #
  # delete the specified file from the specified work on behalf of the specified user
  #
  def delete_fileset( user, fileset )

    print "deleting file set #{fileset.id} (#{fileset.label})... "

    file_actor = ::CurationConcerns::Actors::FileSetActor.new( fileset, user )
    file_actor.destroy

    puts "done"

  end

  #
  # batch process a group of SOLR works
  #
  def batched_process_solr_works( solr_works, &f )

    solr_works.each do |gw_solr|
      begin
        gw = LibraWork.find( gw_solr['id'] )
        f.call( gw )
      rescue => e
        puts e
      end
    end

  end

  #
  # show full details of a libra work
  #
  def show_libra_work( work )

    return if work.nil?
    j = JSON.parse( work.to_json )
    j.keys.sort.each do |k|
      val = j[ k ]
      if k.end_with?( '_id' ) == false && k.end_with?( '_ids' ) == false
        show_field( k, val, ' ' )
      end
    end

    show_field( 'visibility', work.visibility, ' ' )

    Author.sort( work.authors ).each_with_index do |p, ix|
      show_person( " author #{ix + 1}:", p )
    end

    Contributor.sort( work.contributors ).each_with_index do |p, ix|
      show_person( " contributor #{ix + 1}:", p )
    end

    if work.file_sets
      file_number = 1
      fs = work.file_sets.sort { |x, y| x.date_uploaded <=> y.date_uploaded }
      fs.each do |file_set|
        puts " file #{file_number} => #{file_set.label}/#{file_set.title[0]} (/downloads/#{file_set.id})"
        file_number += 1
      end
    end

    puts '*' * 40

  end

  #
  # show the contents of a person sub-field
  #
  def show_person( title, person )

    #puts "#{title} #{person}"
    puts "#{title}"
    show_field( 'ix', person.index, '   ' )
    show_field( 'cid', person.computing_id, '   ' )
    show_field( 'first_name', person.first_name, '   ' )
    show_field( 'last_name', person.last_name, '   ' )
    show_field( 'department', person.department, '   ' )
    show_field( 'institution', person.institution, '   ' )
  end

  #
  # show a field if it is not empty
  #
  def show_field( name, val, indent )
    return if val.nil?
    return if val.respond_to?( :empty? ) && val.empty?
    puts "#{indent}#{name} => #{val}"
  end

  #
  # upload the specified file to the specified work on behalf of the specified user
  #
  def upload_file( user, work, filename, title, visibility )

    print "uploading #{filename}... "

    fileset = ::FileSet.new
    fileset.title << title unless title.nil?
    file_actor = ::CurationConcerns::Actors::FileSetActor.new( fileset, user )
    file_actor.create_metadata( work )
    file_actor.create_content( File.open( filename ) )
    fileset.visibility = visibility
    fileset.save!

    puts "done"
    return fileset

  end

  #
  # get a list of assets in the specified directory that match the supplied pattern
  #
  def get_directory_list( dirname, pattern )
    res = []
    begin
      Dir.foreach( dirname ) do |f|
        if pattern.match( f )
          res << f
        end
      end
    rescue => e
    end

    return res.sort { |x, y| directory_sort_order( x, y ) }
  end

  #
  # so we can process the directories in numerical order
  #
  def directory_sort_order( f1, f2 )
    n1 = File.extname( f1 ).gsub( '.', '' ).to_i
    n2 = File.extname( f2 ).gsub( '.', '' ).to_i
    return -1 if n1 < n2
    return 1 if n1 > n2
    return 0
  end

  #
  # load a file containing json data and return a hash
  #
  def load_json_doc( filename )

    begin
      File.open( filename, 'r') do |file|
        json_str = file.read( )
        doc = JSON.parse json_str
        return doc
      end

    rescue => ex
      puts "ERROR: loading #{filename} (#{ex})"
      return nil
    end

  end

  #
  # load a file containing xml data and return an oga document
  #
  def load_xml_doc( filename )
    File.open( filename, 'r') do |file|
      return Oga.parse_xml( file )
    end

    puts "ERROR: loading #{filename}"
    return nil
  end

  def make_author( cid, ix )

    info = user_info_by_cid( cid )
    return nil if info.nil?

    person = Author.new( index: ix,
                         first_name: info.first_name,
                         last_name: info.last_name,
                         computing_id: cid,
                         department: info.department,
                         institution: LibraWork::DEFAULT_INSTITUTION )
    return( person )
  end

  def make_contributor( cid, ix )

    info = user_info_by_cid( cid )
    return nil if info.nil?

    person = Contributor.new( index: ix,
                              first_name: info.first_name,
                              last_name: info.last_name,
                              computing_id: cid,
                              department: info.department,
                              institution: LibraWork::DEFAULT_INSTITUTION )
    return( person )
  end

end
