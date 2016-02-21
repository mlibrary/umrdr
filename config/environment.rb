# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# Set the default host for resolving _url methods
Rails.application.routes.default_url_options[:host] = 'localhost:3000'

