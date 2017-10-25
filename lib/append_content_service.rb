require 'hydra/file_characterization'
require 'logger'

Hydra::FileCharacterization::Characterizers::Fits.tool_path = `which fits || which fits.sh`.strip

# Given a configuration hash read from a yaml file,
# build the contents in the repository.
class AppendContentService
  def self.call( path_to_config )
    config = YAML.load_file(path_to_config)
    base_path = File.dirname(path_to_config)
    bcs = AppendContentService.new( config, base_path)   
    bcs.run
  end

  attr :cfg, :base_path

  def initialize( config, base_path )
    @cfg = config
    @base_path = base_path
    logger.debug "NEW CONTENT SERVICE AT YOUR ... SERVICE"
  end

  # config needs default user to attribute collections/works/filesets to
  # User needs to have only works or collections
  def config_is_okay?
    if @cfg.keys != [:user]
      logger.error "Top level key needs to be 'user'"
      return false
    end

    if (@cfg[:user].keys <=> [:collections, :works]) < 1
      logger.error "user can only contain collections and works"
      return false
    end

    return true
  end

  def user_key
    @cfg[:user][:email]
  end

  def visibility
    visibility = @cfg[:user][:visibility]
    unless %w[open restricted].include? visibility
     raise "Illegal value '#{visibility}' for visibility" 
    end
    return visibility
  end

  def works
    [@cfg[:user][:works]]
  end

  def collections
    @cfg[:user][:collections]
  end

  def run
    if config_is_okay?
      build_repo_contents
    else
      logger.error("Config Check Failed.")
    end
  end

  def log_object(obj)
    logger.info "id: #{obj.id} title: #{obj.title.first}"
  end

  def build_repo_contents
    user = User.find_by_user_key(user_key) || create_user(user_key)
    if user.nil?
      logger.warn "User not found: #{user_key}"
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

  # build work, file sets, apply metadata, and link up.
  def build_work(w_hsh)
    id = Array(w_hsh[:id])
    owner = Array(w_hsh[:owner])
    gw = GenericWork.find id[0]

    paths_and_names = w_hsh[:files].zip w_hsh[:filenames]
    fsets = paths_and_names.map{|fp| build_file_set(fp[0], fp[1])}
    fsets.each{|fs| gw.ordered_members << fs}
    gw.apply_depositor_metadata(user_key)
    gw.owner=(user_key)
    gw.visibility = visibility
    gw.save!
    return gw
  end

  # If filename not given, use basename from path
  def build_file_set(path, filename=nil)
    fname = filename || File.basename(path)
    logger.info "Processing: #{fname}"
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
    now = DateTime.now.new_offset(0)
    fs.date_uploaded = now
    fs.visibility = visibility
    fs.save!
    logger.info "Finished:   #{fname}"
    return fs
  end

  private

  def logger
    @logger ||= Logger.new(STDOUT).tap {|logger| logger.level = Logger::INFO }
  end
end

