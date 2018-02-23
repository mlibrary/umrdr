module BoxHelper
  # https://github.com/cburnette/boxr
  # http://www.rubydoc.info/gems/boxr/Boxr
  require 'boxr'
  require 'openssl'

  class Box

    @@box_verbose = false

    # {"type"=>"folder", "id"=>"45101723215", "sequence_id"=>"1", "etag"=>"1", "name"=>"ulib-dbd-box"}
    @@ulib_dbd_box_id = '45101723215'.freeze
    @@dlib_dbd_box_user_id = '3200925346'.freeze
    @@box_access_and_refresh_token_file = File.join( Rails.root, 'config', 'box_config.yml' ).freeze

    attr_accessor :dir_list, :parent_dir

    def initialize( access_token: nil,
                    box_client_id: nil,
                    box_client_secret: nil,
                    developer_token: nil, # parent_dir: Boxr::ROOT
                    json_file_path_in: nil,
                    parent_dir: @@ulib_dbd_box_id,
                    refresh_token: nil )

      @parent_dir = parent_dir
      @json_file_path = json_file_path_in
      config_hash_load( assign_attributes: true )
      @developer_token = developer_token unless developer_token.nil?
      @access_token = access_token unless access_token.nil?
      @refresh_token = refresh_token unless refresh_token.nil?
      @box_client_id = box_client_id unless box_client_id.nil?
      @box_client_secret = box_client_secret unless box_client_secret.nil?
      ENV['BOX_CLIENT_ID'] = @box_client_id
      ENV['BOX_CLIENT_SECRET'] == @box_client_secret
    end

    def access_and_refresh_tokens_cache( new_access_token, new_refresh_token )
      puts "cache_access_and_refresh_tokens(#{new_access_token},#{new_refresh_token})" if @@box_verbose
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
      puts "access_and_refresh_tokens_export(#{new_access_token},#{new_refresh_token})" if @@box_verbose
      config_hash = config_hash_current
      config_hash['box_access_token'] = new_access_token
      config_hash['box_refresh_token'] = new_refresh_token
      open( @@box_access_and_refresh_token_file, 'w' ) { |f| f << config_hash.to_yaml << "\n" }
    end

    def access_and_refresh_tokens_load( access_token, refresh_token )
      if access_token.nil? || refresh_token.nil?
        if File.exist? @@box_access_and_refresh_token_file
          yml_hash = config_has_load
          @access_token = yml_hash[:box_access_token]
          @refresh_token = yml_hash[:box_refresh_token]
        end
      end
    end

    def access_token_developer
      # TODO
      'Token goes here, this will not work work'
      'NB4wSgTW4HuoQaXnbHfeFHHUeAqED70Y'.freeze
    end

    def client
      #client_init_developer_token
      client_init_single
      #client_init_json
      @box_client
    end

    def client_init_developer_token
      @access_token = access_token_developer
      @box_client ||= Boxr::Client.new( access_token_developer )
    end

    def client_init_single
      @access_token = access_token_developer
      token_refresh_callback = lambda { |access, refresh, identifier| access_and_refresh_tokens_cache( access, refresh ) }
      @box_client ||= Boxr::Client.new( @access_token,
                           refresh_token: @refresh_token,
                           client_id: @box_client_id,
                           client_secret: @box_client_secret,
                           &token_refresh_callback )
    end

    def client_init_json
      @access_token = access_token_developer
      token_refresh_callback = lambda { |access, refresh, identifier| access_and_refresh_tokens_cache( access, refresh ) }
      @box_client ||= Boxr::Client.new( @access_token,
                                      refresh_token: @refresh_token,
                                      client_id: json_config_client_id,
                                      client_secret: json_config_client_secret,
                                      enterprise_id: json_config_enterprise_id,
                                      jwt_private_key: json_config_private_key,
                                      jwt_private_key_password: json_config_passphrase,
                                      jwt_public_key_id: json_config_public_key_id,
                                      &token_refresh_callback )
    end

    def config_hash_current
      config_hash = Hash.new
      config_hash['box_access_token']    = @access_token.nil?      ? '' : @access_token
      config_hash['box_client_id']       = @box_client_id.nil?     ? '' : @box_client_id
      config_hash['box_client_secret']   = @box_client_secret.nil? ? '' : @box_client_secret
      config_hash['box_developer_token'] = @developer_token.nil?   ? '' : @developer_token
      config_hash['box_refresh_token']   = @refresh_token.nil?     ? '' : @refresh_token
      return config_hash
    end

    def config_hash_load( assign_attributes: false )
      config_hash = YAML.load_file @@box_access_and_refresh_token_file
      config_hash['box_access_token']    = nil if '' == config_hash['box_access_token']
      config_hash['box_client_id']       = nil if '' == config_hash['box_client_id']
      config_hash['box_client_secret']   = nil if '' == config_hash['box_client_secret']
      config_hash['box_developer_token'] = nil if '' == config_hash['box_developer_token']
      config_hash['box_refresh_token']   = nil if '' == config_hash['box_refresh_token']
      if assign_attributes
        @access_token      = config_hash['box_access_token']
        @box_client_id     = config_hash['box_client_id']
        @box_client_secret = config_hash['box_client_secret']
        @developer_token   = config_hash['box_developer_token']
        @refresh_token     = config_hash['box_refresh_token']
      end
      puts "config_hash_load config_hash=#{config_hash}" if @@box_verbose
      return config_hash
    end

    def config_hash_save
      config_hash = config_hash_current
      puts "config_hash_save config_hash=#{config_hash}" if @@box_verbose
      open( @@box_access_and_refresh_token_file, 'w' ) { |f| f << config_hash.to_yaml << "\n" }
    end

    def dir_list
      @dir_list ||= client.folder_items( parent_dir )
    end

    def dir_item_by_name( dir_name )
      dir_list.each do |dir_item|
        return dir_item if dir_item.name == dir_name
      end
      return nil
    end

    def directory_create( dir_name )
      unless directory_exists?( dir_name )
        client.create_folder( dir_name, parent_dir )
        @dir_list = nil
      end
      has_dir_name? dir_name
    end

    def directory_exists?( dir_name )
      rv = has_dir_name?( dir_name )
      return rv
    end

    def directory_list()
      return dir_list
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
      begin
        folder = client.folder_from_path folder_name
      rescue Boxr::BoxrError => e
        # check for Folder not found
      rescue Exception => ignore
      end
      return folder
    end

    def has_dir_name?( dir_name )
      rv = !dir_item_by_name( dir_name ).nil?
      return rv
    end

    def parent_dir=( parent_dir )
      @parent_dir = parent_dir
      @dir_list = nil
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

    def make_dir_owner_dlib_dbd_box( folder_name )
      box_id = folder_name_to_box_id( folder_name )
      unless box_id.nil?
        client.update_folder( box_id, created_by: @@dlib_dbd_box_user_id, modified_by: @@dlib_dbd_box_user_id, owned_by: @@dlib_dbd_box_user_id )
      end
    end

    def upload_link( folder_name )
      box_id = folder_name_to_box_id( folder_name )
      rv = nil
      unless box_id.nil?
        box_link = client.create_shared_link_for_folder( box_id )
        rv = box_link.shared_link.url
      end
      return rv
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

  end

end