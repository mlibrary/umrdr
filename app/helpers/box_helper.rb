module BoxHelper
  # https://github.com/cburnette/boxr
  # http://www.rubydoc.info/gems/boxr/Boxr
  require 'boxr'
  require 'openssl'

  class Box

    # {"type"=>"folder", "id"=>"45101723215", "sequence_id"=>"1", "etag"=>"1", "name"=>"ulib-dbd-box"}
    @@ulib_dbd_box_id = '45101723215'.freeze

    attr_accessor :dir_list, :parent_dir

    def initialize( parent_dir: @@ulib_dbd_box_id ) # parent_dir: Boxr::ROOT
      @parent_dir = parent_dir
    end

    def access_token_developer
      # TODO
      'Token goes here, this will not work work'
      'NB4wSgTW4HuoQaXnbHfeFHHUeAqED70Y'.freeze
    end

    def cache_access_and_refresh_tokens( access_token, refresh_token )
      @access_token = access_token
      @refresh_token = refresh_token
    end

    def client
      #client_init_developer_token
      #client_init_v1
      client_init_json
      @box_client
    end

    def client_init_developer_token
      @access_token = access_token_developer
      @box_client ||= Boxr::Client.new(access_token_developer )
    end

    # def client_init_v1
    #   @access_token = access_token_developer
    #   token_refresh_callback = lambda { |access, refresh, identifier| cache_access_and_refresh_tokens( access, refresh ) }
    #   @access_token = 'todo'
    #   @refresh_token = 'todo'
    #   @box_client ||= Boxr::Client.new( @access_token,
    #                        refresh_token: @refresh_token,
    #                        client_id: 'xa0ut4e8228a8ivf7uz3mjfcm7bnkd41',
    #                        client_secret: '9N8fN1jPl89N1rOsDaiyhcV0hN5Wxbr1',
    #                        &token_refresh_callback )
    # end

    def client_init_json
      @access_token = access_token_developer
      token_refresh_callback = lambda { |access, refresh, identifier| cache_access_and_refresh_tokens( access, refresh ) }
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
      '/Users/fritx/Downloads/81663_4yb4bxgd_config.json'
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

    def upload_link( folder_name )
      box_id = folder_name_to_box_id( folder_name )
      rv = nil
      unless box_id.nil?
        box_link = client.create_shared_link_for_folder( box_id )
        rv = box_link.shared_link.url
      end
      return rv
    end

  end

end