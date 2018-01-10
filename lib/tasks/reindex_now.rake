namespace :solr do

  desc "Reindex solr cores with perform_now."
  task :reindex! => :environment do |t|
    puts "Performing Resolrize now."
    ResolrizeJob2.perform_now
  end

end

desc "Reindex solr from fedora with ResolrizeJob.perform_now."
task :reindex_solr_now => :environment do |t|
  puts "Performing Resolrize now."
  ResolrizeJob2.perform_now
end

