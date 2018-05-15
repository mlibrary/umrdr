module Umrdr
  module FileSetBehavior
    extend ActiveSupport::Concern

    def primary_file_size
      rv = 0
      file = primary_file
      if file.nil?
        rv = original_file.size
      else
        rv = file.size
      end
      return rv
    end

    def primary_file
      rv = nil
      unless ( files.nil? || 0 == files.size )
        rv = files[0]
        files.each do | f |
          rv = f unless f.original_name == ''
        end
      end
      return rv
    end

    def update_parent()
      parent.total_file_size_add_file_set!( self ) unless parent.nil?
    end

    def update_solr_file_size!
      file = primary_file
      file_size = file.size
      save!
    end

  end
end
