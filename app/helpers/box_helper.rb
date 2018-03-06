module BoxHelper
  # https://github.com/cburnette/boxr
  # http://www.rubydoc.info/gems/boxr/Boxr
  require 'boxr'
  require 'openssl'
  require 'thread'

  ## So, is it safe to do this in a module?
  @@mutex_to_guard_token_file
  @@box

  def self.access_and_refresh_token_file_init( box_access_and_refresh_token_file, box_access_and_refresh_token_file_init, verbose: true )
    if File.exist? box_access_and_refresh_token_file_init
      # copy box_access_and_refresh_token_file_init to box_access_and_refresh_token_file
      Rails.logger.error "BoxHelper.access_and_refresh_token_file_init copy #{box_access_and_refresh_token_file_init} to #{box_access_and_refresh_token_file}"
      FileUtils.copy_file( box_access_and_refresh_token_file_init, box_access_and_refresh_token_file )
      FileUtils.move( box_access_and_refresh_token_file_init, box_access_and_refresh_token_file_init + ".initialized" )
    end
  end

  def self.access_token_developer( developer_token: nil,
      app_name: nil,
      client_id: nil,
      client_secret: nil,
      config_file: Umrdr::Application.config.box_access_and_refresh_token_file )

    config_file = find_real_file( config_file )
    config_hash = Hash.new
    config_hash['box_access_token']     = ''
    config_hash['box_app_name']         = app_name
    config_hash['box_client_id']        = client_id
    config_hash['box_client_secret']    = client_secret
    config_hash['box_developer_token']  = developer_token
    config_hash['box_refresh_token']    = ''
    config_hash['box_config_timestamp'] = DateTime.now.to_s
    open( config_file, 'w' ) { |f| f << config_hash.to_yaml << "\n" }
  end

  def self.access_token_fetch( auth_code: nil,
      app_name: nil,
      client_id: nil,
      client_secret: nil,
      config_file: Umrdr::Application.config.box_access_and_refresh_token_file_init )

    rv = `curl https://api.box.com/oauth2/token -d 'grant_type=authorization_code&code=#{auth_code}&client_id=#{client_id}&client_secret=#{client_secret}' -X POST`
    # rv is of the form: {"access_token":"zmAhTjZ0PZG1EkKrsWfOMvMG0lBAGIgS","expires_in":3842,"restricted_to":[],"refresh_token":"NtJfAO0S85uCIx4R6MKqf3YZgcAfbWWlOGcJXmmy9wV8FCSWEqk9bBbCfXbXk6NA","token_type":"bearer"}
    puts "rv=#{rv}"
    if rv.start_with?( "{\"access_token\":" )
      puts "parse and write to #{config_file}"
      json = JSON.parse( rv )
      puts "access_token=#{json['access_token']}"
      puts "refresh_token=#{json['refresh_token']}"

      config_hash = Hash.new
      config_hash['box_access_token']     = json['access_token']
      config_hash['box_app_name']         = app_name
      config_hash['box_client_id']        = client_id
      config_hash['box_client_secret']    = client_secret
      config_hash['box_developer_token']  = ''
      config_hash['box_refresh_token']    = json['refresh_token']
      config_hash['box_config_timestamp'] = DateTime.now.to_s
      open( config_file, 'w' ) { |f| f << config_hash.to_yaml << "\n" }
    else
      puts "don't know how parse rv='#{rv}''"
    end
  end

  def self.access_token_url( app_name: nil, client_id: nil )
    puts
    puts
    puts "Make sure the app #{app_name} has a redirect link to something like http://localhost:9876"
    puts "You will have 30 seconds to run access_token_fetch after you grant access using this url in your browser:"
    puts
    puts "https://account.box.com/api/oauth2/authorize?response_type=code&client_id=#{client_id}"
    puts
  end

  def self.box
    @@box ||= box_initialize
  end

  def self.box_initialize
    mutex_to_guard_token_file
    developer_token = Umrdr::Application.config.box_developer_token
    return Box.new( developer_token: developer_token ) unless ( developer_token.nil? || developer_token.empty? )
    return Box.new
  end

  def self.box_link( dir_name )
    rv = box.upload_link( dir_name )
    return rv
  end

  def self.box_link_display_for_work?( work_id: nil, work_file_count: -1 )
    rv = box.box_link_display_for_work?( work_id: work_id, work_file_count: work_file_count )
    return rv
  end

  def self.create_box_dir( dir_name )
    rv = box.directory_create( dir_name )
    if !rv && box.failed_box_login
      Rails.logger.error "BoxHelper failed to create directory '#{dir_name}' because box failed to log in."
    end
    return rv
  end

  def self.find_real_file( possible_file_link )
    return possible_file_link unless File.exist? possible_file_link
    return File.readlink( possible_file_link ) if 'link' == File.ftype( possible_file_link )
    return possible_file_link
  end

  def self.mutex_to_guard_token_file
    @@mutex_to_guard_token_file ||= Thread::Mutex.new
  end

  class Box
    #include Singleton
    # {"type"=>"folder", "id"=>"45101723215", "sequence_id"=>"1", "etag"=>"1", "name"=>"ulib-dbd-box"}
    # @box_access_and_refresh_token_file = Umrdr::Application.config.box_access_and_refresh_token_file.freeze
    # @box_always_report_not_logged_in_errors = Umrdr::Application.config.box_always_report_not_logged_in_errors
    # @box_create_dirs_for_empty_works = Umrdr::Application.config.box_create_dirs_for_empty_works
    # @box_verbose = false
    # @dlib_dbd_box_user_id = '3200925346'.freeze
    # @ulib_dbd_box_id = '45101723215'.freeze

    attr_reader :box_access_and_refresh_token_file,
                :box_access_and_refresh_token_file_init,
                :box_always_report_not_logged_in_errors,
                :box_create_dirs_for_empty_works,
                :dlib_dbd_box_user_id,
                :ulib_dbd_box_id,
                :box_app_name,
                :box_config_timestamp

    attr_accessor :box_verbose,
                  :box_verbose_show_tokens,
                  :dir_list,
                  :failed_box_login,
                  :most_recent_boxr_error,
                  :parent_dir

    alias directory_list dir_list
    alias ls dir_list
    #alias mkdir directory_create

    def initialize( access_token: nil,
                    box_client_id: nil,
                    box_client_secret: nil,
                    developer_token: nil,
                    json_file_path_in: nil,
                    parent_dir: Umrdr::Application.config.box_ulib_dbd_box_id, # parent_dir: Boxr::ROOT
                    refresh_token: nil )

      @box_verbose_show_tokens = false
      @box_access_and_refresh_token_file = BoxHelper.find_real_file( Umrdr::Application.config.box_access_and_refresh_token_file ).freeze
      @box_access_and_refresh_token_file_init = Umrdr::Application.config.box_access_and_refresh_token_file_init
      BoxHelper.access_and_refresh_token_file_init( @box_access_and_refresh_token_file, @box_access_and_refresh_token_file_init )
      @box_always_report_not_logged_in_errors = Umrdr::Application.config.box_always_report_not_logged_in_errors
      @box_create_dirs_for_empty_works = Umrdr::Application.config.box_create_dirs_for_empty_works
      @box_verbose = Umrdr::Application.config.box_verbose
      @dlib_dbd_box_user_id = Umrdr::Application.config.box_dlib_dbd_box_user_id
      @ulib_dbd_box_id = Umrdr::Application.config.box_ulib_dbd_box_id

      @most_recent_boxr_error = nil
      @failed_box_login = false
      @parent_dir = parent_dir
      @json_file_path = json_file_path_in
      config_hash_load( assign_attributes: true ) if ( developer_token.nil? || developer_token.empty? )
      @developer_token = developer_token unless developer_token.nil?
      @access_token = access_token unless access_token.nil?
      @refresh_token = refresh_token unless refresh_token.nil?
      @box_client_id = box_client_id unless box_client_id.nil?
      @box_client_secret = box_client_secret unless box_client_secret.nil?
      ENV['BOX_CLIENT_ID'] = @box_client_id
      ENV['BOX_CLIENT_SECRET'] == @box_client_secret
    end

    def access_and_refresh_tokens_cache( new_access_token, new_refresh_token )
      msg = ""
      msg = "(#{new_access_token},#{new_refresh_token})" if @box_verbose_show_tokens
      verbose_log_status( "cache_access_and_refresh_tokens",msg ) if @box_verbose
      return if new_access_token.nil?
      return if new_refresh_token.nil?
      if new_access_token != @access_token || new_refresh_token != @refresh_token
        access_and_refresh_tokens_export( new_access_token, new_refresh_token )
      end
      @access_token = new_access_token
      @refresh_token = new_refresh_token
    end

    def access_and_refresh_tokens_export( new_access_token, new_refresh_token )
      return if new_access_token.nil?
      return if new_refresh_token.nil?
      msg = ""
      msg = "(#{new_access_token},#{new_refresh_token})" if @box_verbose_show_tokens
      verbose_log_status( "access_and_refresh_tokens_export", msg ) if @box_verbose
      config_hash = config_hash_current
      config_hash['box_access_token'] = new_access_token
      config_hash['box_refresh_token'] = new_refresh_token
      BoxHelper.mutex_to_guard_token_file.synchronize do
        config_hash['box_config_timestamp'] = DateTime.now.to_s
        open( @box_access_and_refresh_token_file, 'w' ) { |f| f << config_hash.to_yaml << "\n" }
      end
    end

    def access_and_refresh_tokens_load( access_token, refresh_token )
      if access_token.nil? || refresh_token.nil?
        if File.exist? @box_access_and_refresh_token_file
          yml_hash = config_hash_load
          @access_token = yml_hash[:box_access_token]
          @refresh_token = yml_hash[:box_refresh_token]
        end
      end
    end

    def access_token_developer
      return @developer_token
    end

    def boxr_error_handle( method: nil, error: nil, backtrace: false )
      @most_recent_boxr_error = error
      #
      # TODO: find the other errors to handle here
      #
      case error.status
      when 400
      when 401
        if @box_always_report_not_logged_in_errors || !@failed_box_login
          boxr_error_log( method: method, error: error, backtrace: backtrace )
        end
        @failed_box_login = true
      when 405
        # this can happen for bad parameters, like passing nil to client.folder_items
        boxr_error_log( method: method, error: error, backtrace: backtrace )
      else
        boxr_error_log( method: method, error: error, backtrace: backtrace )
      end
    end

    def boxr_error_log( method: nil, error: nil, backtrace: false )
      msg = "BoxHelper::Box.#{method} #{error.class}: #{error.message}"
      msg += " at #{error.backtrace[0]}" if backtrace
      Rails.logger.error msg
    end

    def box_link_display_for_work?( work_id: nil, work_file_count: -1 )
      verbose_log_status( "box_link_display_for_work?", "(#{work_id},#{work_file_count})" ) if @box_verbose
      return false if work_id.nil?
      return false if work_file_count < 0
      dir_exists = directory_exists?( work_id )
      if !dir_exists && @box_create_dirs_for_empty_works && work_file_count < 1
        dir_exists = directory_create( work_id )
      end
      return dir_exists
    end

    def client
      return @box_client unless @box_client.nil?
      client_init_developer_token unless ( @developer_token.nil? || @developer_token.empty? )
      client_init_single if @box_client.nil?
      #client_init_json
      return @box_client
    end

    def client_init_developer_token
      verbose_log_status( "client_init_developer_token", "" ) if @box_verbose
      return unless @box_client.nil?
      msg = ""
      msg = " access_token_developer=#{access_token_developer}" if @box_verbose_show_tokens
      verbose_log_status( "client_init_developer_token", msg ) if @box_verbose
      begin
        @box_client = Boxr::Client.new( access_token_developer )
        verbose_log_status( "client_init_developer_token", " initialized box" ) if @box_verbose
      rescue Boxr::BoxrError => e
        boxr_error_log( method: "client_init_developer_token", error: e )
        @box_client = nil
      end
    end

    def client_init_single
      verbose_log_status( "client_init_single", "" ) if @box_verbose
      return unless @box_client.nil?
      token_refresh_callback = lambda { |access, refresh, identifier| access_and_refresh_tokens_cache( access, refresh ) }
      begin
        @box_client = Boxr::Client.new( @access_token,
                             refresh_token: @refresh_token,
                             client_id: @box_client_id,
                             client_secret: @box_client_secret,
                             &token_refresh_callback )
        verbose_log_status( "client_init_single", " initialized box" ) if @box_verbose
      rescue Boxr::BoxrError => e
        boxr_error_log( method: "client_init_single", error: e )
        @box_client = nil
      end
    end

    # def client_init_json
    #   @access_token = access_token_developer
    #   token_refresh_callback = lambda { |access, refresh, identifier| access_and_refresh_tokens_cache( access, refresh ) }
    #   @box_client ||= Boxr::Client.new( @access_token,
    #                                   refresh_token: @refresh_token,
    #                                   client_id: json_config_client_id,
    #                                   client_secret: json_config_client_secret,
    #                                   enterprise_id: json_config_enterprise_id,
    #                                   jwt_private_key: json_config_private_key,
    #                                   jwt_private_key_password: json_config_passphrase,
    #                                   jwt_public_key_id: json_config_public_key_id,
    #                                   &token_refresh_callback )
    # end

    def config_hash_current
      config_hash = Hash.new
      config_hash['box_access_token']     = @access_token.nil?         ? '' : @access_token
      config_hash['box_app_name']         = @box_app_name.nil?         ? '' : @box_app_name
      config_hash['box_client_id']        = @box_client_id.nil?        ? '' : @box_client_id
      config_hash['box_client_secret']    = @box_client_secret.nil?    ? '' : @box_client_secret
      config_hash['box_config_timestamp'] = @box_config_timestamp.nil? ? '' : @box_config_timestamp
      config_hash['box_developer_token']  = @developer_token.nil?      ? '' : @developer_token
      config_hash['box_refresh_token']    = @refresh_token.nil?        ? '' : @refresh_token
      return config_hash
    end

    def config_hash_load( assign_attributes: false )
      config_hash = nil
      BoxHelper.mutex_to_guard_token_file.synchronize do
        config_hash = YAML.load_file @box_access_and_refresh_token_file
      end
      config_hash['box_access_token']     = nil if '' == config_hash['box_access_token']
      config_hash['box_app_name']         = nil if '' == config_hash['box_app_name']
      config_hash['box_client_id']        = nil if '' == config_hash['box_client_id']
      config_hash['box_client_secret']    = nil if '' == config_hash['box_client_secret']
      config_hash['box_config_timestamp'] = nil if '' == config_hash['box_config_timestamp']
      config_hash['box_developer_token']  = nil if '' == config_hash['box_developer_token']
      config_hash['box_refresh_token']    = nil if '' == config_hash['box_refresh_token']
      if assign_attributes
        @access_token         = config_hash['box_access_token']
        @bbox_app_name        = config_hash['box_app_name']
        @box_client_id        = config_hash['box_client_id']
        @box_client_secret    = config_hash['box_client_secret']
        @box_config_timestamp = config_hash['box_config_timestamp']
        @developer_token      = config_hash['box_developer_token']
        @refresh_token        = config_hash['box_refresh_token']
      end
      msg = " load config_hash"
      msg = " load config_hash=#{config_hash}" if @box_verbose_show_tokens
      verbose_log_status( "config_hash", msg ) if @box_verbose
      return config_hash
    end

    def config_hash_save
      config_hash = config_hash_current
      msg = ""
      msg = " config_hash=#{config_hash}" if @box_verbose_show_tokens
      verbose_log_status( "config_hash_save", msg ) if @box_verbose
      BoxHelper.mutex_to_guard_token_file.synchronize do
        config_hash['box_config_timestamp'] = DateTime.now.to_s
        open( @box_access_and_refresh_token_file, 'w' ) { |f| f << config_hash.to_yaml << "\n" }
      end
    end

    def dir_list
      return [] if failed_box_login
      @dir_list ||= client.folder_items( parent_dir )
    rescue Boxr::BoxrError => e
      boxr_error_handle( method: "dir_list", error: e )
      return []
    end

    def dir_item_by_name( dir_name )
      dir_list.each do |dir_item|
        return dir_item if dir_item.name == dir_name
      end
      return nil
    end

    def directory_create( dir_name )
      verbose_log_status( "directory_create", "(#{dir_name})" ) if @box_verbose
      return false if failed_box_login
      unless directory_exists?( dir_name )
        verbose_log_status( "directory_create", " client.create_folder(#{dir_name})" ) if @box_verbose
        client.create_folder( dir_name, parent_dir )
        @dir_list = nil
      end
      return has_dir_name? dir_name
    rescue Boxr::BoxrError => e
      boxr_error_handle( method: "directory_create", error: e )
      return false
    end

    def directory_exists?( dir_name )
      rv = has_dir_name?( dir_name )
      return rv
    end

    def directory_list_names()
      rv = dir_list.map { |i| i.name }
      return rv
    end

    def folder_name_to_box_id( folder_name )
      dir_item = dir_item_by_name( folder_name )
      rv = nil
      unless dir_item.nil?
        rv = dir_item.id
      end
      return rv
    end

    def folder_from_path( folder_name )
      folder = nil
      return folder if failed_box_login
      begin
        folder = client.folder_from_path folder_name
      rescue Boxr::BoxrError => e
        # check for Folder not found
        boxr_error_handle(method: "folder_from_path", error: e )
      rescue Exception => ignore
      end
      return folder
    end

    def has_dir_name?( dir_name )
      verbose_log_status( "has_dir_name?", "(#{dir_name})" ) if @box_verbose
      rv = !dir_item_by_name( dir_name ).nil?
      return rv
    end

    def parent_dir=( parent_dir )
      need_refresh = @parent_dir != parent_dir
      @parent_dir = parent_dir
      refresh if need_refresh
    end

    def json_file_path
      #TODO: move this file to umrder config somewhere
      return @json_file_path unless @json_file_path.nil?
      return '/Users/fritx/Downloads/81663_u5qyqszl_config.json'
    end

    def json_config
      @json_config ||= JSON.parse( File.read( json_file_path ) )
    end

    def json_config_client_id
      json_config["boxAppSettings"]["clientID"]
    end

    def json_config_client_secret
      json_config["boxAppSettings"]["clientSecret"]
    end

    def json_config_enterprise_id
      json_config["enterpriseID"]
    end

    def json_config_passphrase
      json_config["boxAppSettings"]["appAuth"]["passphrase"]
    end

    def json_config_private_key
      json_config["boxAppSettings"]["appAuth"]["privateKey"]
    end

    def json_config_public_key_id
      json_config["boxAppSettings"]["appAuth"]["publicKeyID"]
    end

    def private_key
      #rv = OpenSSL::PKey::RSA.new( File.read( ENV['JWT_PRIVATE_KEY_PATH']), ENV['JWT_PRIVATE_KEY_PASSWORD'] )
      rv = OpenSSL::PKey::RSA.new( json_config_private_key, json_config_passphrase )
      rv
    end

    def refresh
      @dir_list = nil
     end

    def reset
      @box_client = nil
      @dir_list = nil
      @most_recent_boxr_error = nil
      @failed_box_login = false
    end

    # def make_dir_owner_dlib_dbd_box( folder_name )
    #   box_id = folder_name_to_box_id( folder_name )
    #   unless box_id.nil?
    #     client.update_folder( box_id, created_by: @dlib_dbd_box_user_id, modified_by: @dlib_dbd_box_user_id, owned_by: @dlib_dbd_box_user_id )
    #   end
    # end

    def upload_link( folder_name )
      verbose_log_status( "upload_link", "(#{folder_name})" ) if @box_verbose
      box_id = folder_name_to_box_id( folder_name )
      rv = "https://umich.app.box.com/folder/#{@ulib_dbd_box_id}"
      if !failed_box_login && !box_id.nil?
        box_link = client.create_shared_link_for_folder( box_id )
        rv = box_link.shared_link.url
      end
      verbose_log_status( "upload_link", " returning #{rv}" ) if @box_verbose
      return rv
    rescue Boxr::BoxrError => e
      boxr_error_handle( method: "upload_link", error: e )
      return "https://umich.app.box.com/folder/#{@ulib_dbd_box_id}"
    end

    # def update_folder(folder, name: nil, description: nil, parent: nil, shared_link: nil,
    #                   folder_upload_email_access: nil, owned_by: nil, sync_state: nil, tags: nil,
    #                   created_by: nil, modified_by: nil,
    #                   can_non_owners_invite: nil, if_match: nil)
    #   folder_id = ensure_id(folder)
    #   parent_id = ensure_id(parent)
    #   created_by_id = ensure_id( created_by )
    #   modified_by_id = ensure_id( modified_by )
    #   owned_by_id = ensure_id(owned_by)
    #   uri = "#{FOLDERS_URI}/#{folder_id}"
    #
    #   puts "#{created_by_id}"
    #
    #   attributes = {}
    #   attributes[:name] = name unless name.nil?
    #   attributes[:description] = description unless description.nil?
    #   attributes[:parent] = {id: parent_id} unless parent_id.nil?
    #   attributes[:shared_link] = shared_link unless shared_link.nil?
    #   attributes[:folder_upload_email] = {access: folder_upload_email_access} unless folder_upload_email_access.nil?
    #   attributes[:owned_by] = {id: owned_by_id} unless owned_by_id.nil?
    #   attributes[:created_by] = {id: created_by_id} unless created_by_id.nil?
    #   attributes[:modified_by] = {id: modified_by_id} unless modified_by_id.nil?
    #   attributes[:sync_state] = sync_state unless sync_state.nil?
    #   attributes[:tags] = tags unless tags.nil?
    #   attributes[:can_non_owners_invite] = can_non_owners_invite unless can_non_owners_invite.nil?
    #
    #   updated_folder, response = put(uri, attributes, if_match: if_match)
    #   updated_folder
    # end

    def verbose_log( method_name, msg )
      Rails.logger.debug "BoxHelper::Box #{method_name}#{msg}"
    end

    def verbose_log_status( method_name, msg )
      Rails.logger.debug "BoxHelper::Box failed_box_login=#{failed_box_login}: #{method_name}#{msg}"
    end

  end

end