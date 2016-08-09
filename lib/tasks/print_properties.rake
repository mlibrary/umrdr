namespace :umrdr do
  # Use given single class name arg or default to GenericWork
  desc "Print properties of a sub-class of ActiveFedora::Base"
  task :properties_to_csv, [:class_name] => :environment do |t, args|
    Rails.application.eager_load!
    class_name = args.one? ? args[:class_name] : "GenericWork"
    print_properties_of class_name.constantize
  end
end

# Given a class, print some properties information as csv
def print_properties_of(klass)
  #Check if klass is subclass of ActiveFedora::Base
  if klass <= ActiveFedora::Base
    klass.properties.each do |key, prop|
      puts [key, prop.predicate].join(',')
    end
  else
    puts "#{klass} is not ActiveFedora::Base nor a subclass thereof."
  end
end

