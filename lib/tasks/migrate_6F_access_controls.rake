
# Does not need to be ported to DBDv2

require_relative '../migrate_service_six'
namespace :umrdr do

  desc "Migrate ACL, desc md, and tech md for all"
  task :migrate_6f_all => :environment do |t|
    Rake::Task["umrdr:migrate_6f_acl_md"].execute
    Rake::Task["umrdr:migrate_6f_ch13n"].execute
  end

  desc "Migrate 6f status report"
  task :migrate_6f_status => :environment do |t|
    report = MigrateServiceSix.status
    puts "#{report[:works_need_acl_only].count} works need acl migration only."
    puts "#{report[:works_need_dsc_only].count} works need meta migration only."
    puts "#{report[:works_need_acl_dsc].count} works need both migrations."
    puts "#{report[:file_sets_need_acl_only].count} file sets need acl migration."
    puts "#{report[:file_sets_need_tech].count} file sets need characterization."
  end

  desc "Migrate Metadata and ACLs for Sufia6F works."
  task :migrate_6f_acl_md => :environment do |t|
    ENV["RAILS_ENV"] ||= "development"

    # Permissions migration needs instance of MigrateService
    migrator = MigrateServiceSix.new

    acl_works        = MigrateServiceSix.works_with_empty_permissions
    acl_file_sets    = MigrateServiceSix.file_sets_with_empty_permissions
    acl_collections  = MigrateServiceSix.collections_with_empty_permissions
    meta_works       = MigrateServiceSix.works_with_missing_metadata
    meta_collections = MigrateServiceSix.collections_with_missing_metadata

    both_works = acl_works.select{|work| meta_works.include? work}
    acl_works.reject!{|work| both_works.include? work}
    meta_works.reject!{|work| both_works.include? work}

    puts "#{acl_works.count} works need acl migration only."
    puts "#{meta_works.count} works need meta migration only."
    puts "#{both_works.count} works need both migrations."
    puts "#{acl_file_sets.count} file sets need acl migration."
    puts "#{acl_collections.count} collections need acl migration."
    puts "#{meta_collections.count} collections need metadata migration."

    both_works.each do |work|
      MigrateServiceSix.migrate_metadata_for work
      migrator.migrate_permissions_for work
    end

    acl_file_sets.each do |fileset|
      migrator.migrate_permissions_for fileset
    end

    acl_collections.each do |collection|
      migrator.migrate_permissions_for collection
    end

    meta_collections.each do |collection|
      MigrateServiceSix.migrate_metadata_for collection
    end
  end

  desc "Migrate Sufia6F tech md by running characterization."
  task :migrate_6f_ch13n => :environment do |t|
    ENV["RAILS_ENV"] ||= "development"
    filesets = MigrateServiceSix.file_sets_missing_metadata
    puts "#{filesets.count} files with missing technical metadata."
    filesets.each do |fileset|
      puts "Running characterization for #{fileset.id}"
      begin
        CharacterizeJob.perform_now(fileset, fileset.original_file.id)
      rescue StandardError => my_ex
        puts "Error for #{fileset.id}"
        puts my_ex
      end
    end
  end

  desc "Migrate Sufia6F Based Works Access Controls."
  task :migrate_6f_works_acl => :environment do |t|
    ENV["RAILS_ENV"] ||= "development"

    # Find Works with empty permissions.  This is how they will appear to the Sufia7 codebase.
    works = MigrateServiceSix.works_with_empty_permissions
    puts "#{works.count} GenericWork with empty permissions."

    works.each do |work|
      MigrateServiceSix.migrate_permissions_for work
    end

    puts "Done."
  end

  desc "Migrate work descriptive metadata fields."
  task :migrate_6f_works_md => :environment do |t|
    ENV["RAILS_ENV"] ||= "development"

    works = MigrateServiceSix.works_with_missing_metadata
    puts "#{works.count} works with missing metadata."

    works.each do |work|
      MigrateServiceSix.update_metadata_of work
    end
  end
end
