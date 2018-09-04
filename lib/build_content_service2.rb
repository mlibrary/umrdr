# frozen_string_literal: true

# Ported to DBDv2

require 'tasks/new_content_service2'

# Given a configuration hash read from a yaml file,
# build the contents in the repository.
class BuildContentService2 < Umrdr::NewContentService2

  def self.call( path_to_yaml_file:, mode: nil, ingester: nil, options:, args: )
    cfg_hash = YAML.load_file( path_to_yaml_file )
    base_path = File.dirname( path_to_yaml_file )
    bcs = BuildContentService2.new( path_to_yaml_file: path_to_yaml_file,
                                   cfg_hash: cfg_hash,
                                   base_path: base_path,
                                   mode: mode,
                                   ingester: ingester,
                                   options: options,
                                   args: args )
    bcs.run
  rescue Exception => e
    Rails.logger.error "BuildContentService2.call(#{path_to_yaml_file}) #{e.class}: #{e.message} at\n#{e.backtrace.join("\n")}"
  end

  def initialize( path_to_yaml_file:, cfg_hash:, base_path:, mode:, ingester:, options:, args: )
    initialize_with_msg( args: args,
                         options: options,
                         path_to_yaml_file: path_to_yaml_file,
                         cfg_hash: cfg_hash,
                         base_path: base_path,
                         mode: mode,
                         ingester: ingester,
                         msg: "BUILD CONTENT SERVICE AT YOUR ... SERVICE" )
  end

  protected

  def build_repo_contents
    build_works
    build_collections
    report_measurements( first_label: 'id' )
  rescue Exception => e
    Rails.logger.error "BuildContentService2.build_repo_contents #{e.class}: #{e.message} at\n#{e.backtrace.join("\n")}"
  end

end
