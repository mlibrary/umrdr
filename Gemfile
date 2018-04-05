source 'https://rubygems.org'


# Force a newer json for 2.4 compatibility
gem 'json', '~>1.8.0'
# Added Gems
gem 'hyrax', '1.0.5'
# When the hyrax gem is updated, check whether the following files are still needed:
# * app/views/hyrax/admin/stats/_deposits.html.erb
# * app/views/hyrax/admin/stats/_new_users.html.erb

gem 'hydra-head', github: 'mlibrary/hydra-head', branch: 'stream-files-10_5'

gem 'flipflop', github: 'voormedia/flipflop'
gem 'blacklight_advanced_search', '~> 6.0'

# EZID client from Duke
gem 'ezid-client'
#a LDAP client
gem 'net-ldap'
# Webserver
gem 'puma'
gem 'mail_form'

gem 'rdf'
gem 'rdf-reasoner'
# Date range support
gem 'edtf'
# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.4.10'

# Pinning Rack commit that resolves the large file upload issue
# When 2.0.4 is out this might not be needed anymore
# See: https://tools.lib.umich.edu/jira/browse/DBD-920
gem 'rack', git: 'https://github.com/rack/rack.git', ref: 'ee01748'

gem 'config'

# Gems added by generator
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'resque'
gem 'resque-pool'
gem 'resque-web', '~> 0.0.7', require: 'resque_web'
gem 'loofah', '~> 2.2.1'
# 3.5.1 breaks simple_fields_for for custom form objects -- https://github.com/plataformatec/simple_form/issues/1549
gem 'simple_form', '~> 3.2', '<= 3.5.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
# will load new rubyzip version
gem 'rubyzip', '>=1.0.0'

gem 'clamav-client'

gem 'boxr'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # gem 'byebug'
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'factory_girl_rails', require: false
  gem 'rspec-rails'
  gem 'rspec-activemodel-mocks'
  gem 'solr_wrapper', '>= 0.3'
  gem 'fcrepo_wrapper', '~> 0.1'
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'rails-controller-testing'
  gem 'rspec-html-matchers'
end

group :development do
  gem 'engine_cart'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'ffaker'
end

gem 'rsolr'
gem 'devise'
gem 'devise-guests'

gem 'skylight'

