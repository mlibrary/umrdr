# Class to encapsulate the logic required to migrate the repository objects from sufia6F to sufia7 code base.
class MigrateServiceSix

  # Cache the full set of ACLS so we don't have to keep asking for them.
  attr :all_acls

  def all_acls
    @all_acls ||= Hydra::AccessControls::Permission.all
  end

  # Find the legacy access controls From the Sufia.Frakenversion (Sufia6F) codebase.
  # Create equivalent_permissions for the GenericWork or FileSet.
  # Destroy the legacy access controls.
  def migrate_permissions_for(object)
      # Find any access controls for this work.  The must be sufia6F style in order to not show up on the Work.
      legacy_access_controls = access_controls_for object
      puts "#{legacy_access_controls.count} AccessControls for #{object.class}: #{object.id}"
      puts "#{object.permissions}"

      # Create equivalent access controls
      self.class.make_equivalent_permissions( object, legacy_access_controls )
      puts "Created equivalent permissions."
      puts "#{object.permissions}"

      # Destroy legacy_access_controls
      if object.save
        puts "Able to save #{object.class} with new permissions.  Destroying old access controls."
        legacy_access_controls.each{ |ac| ac.destroy }
      else
        puts "Unable to save #{object.class}."
      end
  end 

  # Sift through all AccessControls and fine the ones that specify access to the given work id.
  def access_controls_for(object)
    all_acls.select{ |ac| ac.access_to_id == object.id }
  end

  class << self
    # Status of Repository.  Dependent on the solr index state.
    def status 
      acl_works        = works_with_empty_permissions
      acl_file_sets    = file_sets_with_empty_permissions
      acl_collections  = collections_with_empty_permissions
      meta_works       = works_with_missing_metadata
      meta_file_sets   = file_sets_missing_metadata

      both_works = acl_works.select{|work| meta_works.include? work}
      acl_works.reject!{|work| both_works.include? work}
      meta_works.reject!{|work| both_works.include? work}

      report = {works_need_acl_only:     acl_works, 
                works_need_dsc_only:     meta_works,
                works_need_acl_dsc:      both_works,
                file_sets_need_acl_only: acl_file_sets,
                file_sets_need_tech:     meta_file_sets,
                collections_need_acl:    acl_collections}
    end

    # Get array of GenericWorks that are missing creator and description metadata.
    def works_with_missing_metadata
      GenericWork.all.select do |gw|
        gw.description == [] && gw.creator == []
      end
    end

    def collections_with_missing_metadata
      Collection.all.select do |col|
        col.description == [] && col.creator == []
      end
    end

    # Get array of FileSets that have an original file which is missing technical metadata.
    # Minimally, check for size as a surrogate.
    def file_sets_missing_metadata
      FileSet.all.select do |fs|
        fs.original_file && fs.original_file.file_size == []
      end
    end

    # Get list of GenericWorks that are still using the v6.Franensufia style of access controls.
    # These will appear empty from the v7 based code.
    def works_with_empty_permissions
      GenericWork.all.select{|gw| gw.permissions.empty?}
    end

    def file_sets_with_empty_permissions
      FileSet.all.select{|fs| fs.permissions.empty?}
    end

    def collections_with_empty_permissions
      Collection.all.select{|col| col.permissions.empty?}
    end

    # Mutate the work.  Make new permission based on access control
    def make_equivalent_permissions(object, access_controls)
      access_controls.each{ |access_ctl| object.permissions.build access_ctl.to_hash }
    end

    # Take property value from Sufia6F predicate DC.creator
    # write it to the current property (which uses DC11.creator as the predicate)
    def update_creator_of(object)
      object.creator = object.get_values(::RDF::Vocab::DC.creator)
    end

    def update_description_of(object)
      object.description = object.get_values(::RDF::Vocab::DC.description)
    end

    def migrate_metadata_for(object)
      puts "Updating metadata for #{object.class} #{object.id}"
      update_creator_of object
      update_description_of object

      if object.save
        puts "#{object.class} #{object.id} persisted."
      else
        puts "Unable to save #{object.class} #{object.id}."
      end
    end
  end # of class methods
end # of class
