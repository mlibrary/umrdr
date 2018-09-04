
# TODO: does this need to be ported to DBDv2?

unless Rails.env.production?
require 'yaml'

require 'ffaker'

namespace :umrdr do

  desc "Populate app with much fake data."
  task :populate_fake_data, [:path_to_config] => :environment do |t, args|
    ENV["RAILS_ENV"] ||= "development"

    fake_setup

    puts "Done."
  end
end

def fake_setup
  users = User.all.to_a
  num_users = ( ENV['NUM_USERS'] || '10' ).to_i
  num_users -= users.length
  (0..num_users).each do |idx|
    email = FFaker::Internet.email
    user = User.find_by( email: email ) || create_user( email )
    users << user
  end
  num_works = ( ENV['NUM_WORKS'] || '100' ).to_i
  (0..num_works).each do |idx|
    user = users[rand(users.length)]
    work = GenericWork.new(
      title: [FFaker::Movie.title],
      owner: user.user_key,
      creator: [user.user_key],
      description: [FFaker::Ipsum.paragraph],
      methodology: FFaker::Ipsum.paragraph,
      rights: ['http://creativecommons.org/publicdomain/zero/1.0/'],
      tag:FFaker::CheesyLingo.words,
      date_created: [FFaker::Time.date],
    )
    work.apply_depositor_metadata(user.user_key)
    work.save

    STDERR.puts "-- installed #{work.title[0]} : #{user.user_key} : #{work.id}"
  end
end
end
