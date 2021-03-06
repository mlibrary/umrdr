# frozen_string_literal: true

# Ported from DBDv2

require 'yaml'
require_relative '../build_content_service2'
require_relative '../append_content_service2'

namespace :umrdr do

  # bundle exec rake umrdr::populate2[/deepbluedata_prep/w_9019s2443_populate]
  desc "Populate(v2) app with users,collections,works,files."
  # See: https://stackoverflow.com/questions/825748/how-to-pass-command-line-arguments-to-a-rake-task
  task :populate2, [:path_to_yaml_file] => :environment do |_t, args|
    ENV["RAILS_ENV"] ||= "development"
    # See: Rake::TaskArguments for args class
    puts "args=#{args}"
    # puts "args=#{JSON.pretty_print args.to_hash.as_json}"
    args.one? ? content_build( path_to_yaml_file: args[:path_to_yaml_file], args: args ) : content_demo
    puts "Done."
  end

  # bundle exec rake umrdr::append2[/deepbluedata_prep/w_9019s2443_populate]
  desc "Append(v2) files to existing collections."
  task :append2, [:path_to_yaml_file] => :environment do |_t, args|
    ENV["RAILS_ENV"] ||= "development"
    args.one? ? content_append( path_to_yaml_file: args[:path_to_yaml_file], args: args ) : content_demo
    puts "Done."
  end

end

def content_append( path_to_yaml_file:, args: )
  return unless valid_path_to_yaml_file? path_to_yaml_file
  AppendContentService2.call( path_to_yaml_file: path_to_yaml_file, args: args )
end

def content_build( path_to_yaml_file:, args: )
  return unless valid_path_to_yaml_file? path_to_yaml_file
  BuildContentService2.call( path_to_yaml_file: path_to_yaml_file, args: args )
end

def content_demo
  # Create user if user doesn't already exist
  email = 'demouser@example.com'
  user = User.find_by( email: email ) || create_user( email: email )
  puts "user: #{user.user_key}"

  # Create work and attribute to user if they don't already have at least one.
  return unless GenericWork.where( Solrizer.solr_name('depositor', :symbol) => user.user_key ).count < 1
  create_demo_work( user: user )
  puts "demo work created."
end

def create_user( email: 'demouser@example.com' )
  pwd = "password"
  User.create!( email: email, password: pwd, password_confirmation: pwd )
end

def create_demo_work( user: )
  # It did not like attribute tag - need to find
  gw = GenericWork.new( title: ['Demowork'], owner: user.user_key, description: ["A demonstration work for populating the repo."])
  gw.apply_depositor_metadata(user.user_key)
  gw.visibility = "open"
  gw.save
end

def valid_path_to_yaml_file?( path_to_yaml_file )
  return true if File.exist? path_to_yaml_file
  puts "Bad path to config: #{path_to_yaml_file}"
  return false
end
