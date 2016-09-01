namespace :solr do
  desc "Reindex solr cores with perform_now."
  task :reindex! => :environment do |t|
    puts "Performing Resolrize now."
    ResolrizeJob.perform_now
  end
end
