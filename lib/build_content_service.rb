require 'hydra/file_characterization'

Hydra::FileCharacterization::Characterizers::Fits.tool_path = `which fits || which fits.sh`.strip

# Given a configuration hash read from a yaml file,
# build the contents in the repository.
class BuildContentService
  def self.call( path_to_config )
    config = YAML.load_file(path_to_config)
    base_path = File.dirname(path_to_config)
    bcs = BuildContentService.new( config, base_path)   
    puts "NEW CONTENT SERVICE AT YOUR ... SERVICE"
    bcs.config_is_okay? ? bcs.run : puts("Config Check Failed.")
  end

  attr :cfg, :base_path

  def initialize( config, base_path )
    @cfg = config
    @base_path = base_path
  end

  # config needs default user to attribute collections/works/filesets to
  # User needs to have only works or collections
  def config_is_okay?
    if @cfg.keys != [:user]
      puts "Top level key needs to be 'user'"
      return false
    end

    if (@cfg[:user].keys <=> [:collections, :works]) < 1
      puts "user can only contain collections and works"
      return false
    end

    return true
  end

  def user_key
    @cfg[:user][:email]
  end

  def works
    [@cfg[:user][:works]]
  end

  def collections
    @cfg[:user][:collections]
  end

  def run
    # build the stuff described in the config
    build_repo_contents
  end

  def log_object(obj)
    puts "id: #{obj.id} title: #{obj.title.first}"
  end

  def build_repo_contents
    user = User.find_by_user_key(user_key) || create_user(user_key)
    if user.nil?
      puts "User not found."
      return
    end

    # build works
    if works
      works.each do |work_hash|
        log_object(build_work(work_hash))
      end
    end

    # build collections
    collections.each{|coll_hsh| build_collection(coll_hsh)} if collections
  end

  # build collection then call build_work
  def build_collection(c_hsh)
    title = c_hsh['title']
    desc  = c_hsh['desc']
    col = Collection.new(title: title, description: desc, creator: Array(user_key))
    col.apply_depositor_metadata(user_key)

    # Build all the works in the collection
    works_info = Array(c_hsh['works'])
    c_works = works_info.map{|w| build_work(w)}

    # Add each work to the collection
    c_works.each{|cw| col.members << cw}

    col.save!
  end

  # build work, file sets, apply metadata, and link up.
  def build_work(w_hsh)
    title = Array(w_hsh[:title])
    creator = Array(w_hsh[:creator])
    rights = Array(w_hsh[:rights])
    desc  = Array(w_hsh[:description])
    methodology = w_hsh[:methodology] || "No Methodology Available"
    subject = Array(w_hsh[:subject])
    contributor  = Array(w_hsh[:contributor])
    date_created = Array(w_hsh[:date_created])   
    rtype = Array(w_hsh[:resource_type] || 'Dataset')

    gw = GenericWork.new( title: title, creator: creator, rights: rights,
                         description: desc, resource_type: rtype,
                         methodology: methodology, subject: subject,
                         contributor: contributor, date_created: date_created ) 

    paths_and_names = w_hsh[:files].zip w_hsh[:filenames]
    fsets = paths_and_names.map{|fp| build_file_set(fp[0], fp[1])}
    fsets.each{|fs| gw.ordered_members << fs}
    gw.apply_depositor_metadata(user_key)
    gw.owner=(user_key)
    gw.visibility = "open"
    gw.save!
    return gw
  end

  # If filename not given, use basename from path
  def build_file_set(path, filename=nil)
    fname = filename || File.basename(path)
    file = File.open(path)
    #So that filename comes from the name of the file
    #And not the hash
    file.define_singleton_method(:original_name) do
      fname
    end

    fs = FileSet.new()
    fs.apply_depositor_metadata(user_key)
    Hydra::Works::UploadFileToFileSet.call(fs, file)    
    fs.title = Array(fname)
    fs.label = fname
    fs.date_uploaded = Date.today.strftime('%F')
    fs.visibility="open"
    fs.save
    return fs
  end
end

