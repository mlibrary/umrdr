module BoxHelper
  # https://github.com/cburnette/boxr
  # http://www.rubydoc.info/gems/boxr/Boxr
  require 'boxr'

  class Box

    attr_accessor :dir_list, :parent_dir

    def initialize( parent_dir: Boxr::ROOT )
      @parent_dir = parent_dir
    end

    def access_token
      # TODO
      'Token goes here, this will not work work'
    end

    def client
      @box_client ||= Boxr::Client.new( access_token )
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