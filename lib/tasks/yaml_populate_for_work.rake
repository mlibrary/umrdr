require 'open-uri'

desc 'Yaml populate from work'
task :yaml_populate_from_work => :environment do
  Umrdr::YamlPopulateFromWork.run
end

module Umrdr

  # TODO: parametrize the work id
  # TODO: parametrize the target directory
  class YamlPopulateFromWork

    def self.run
      MetadataHelper.yaml_generic_work_populate( 'j6731380t', export_files: true )
    end

  end

end
