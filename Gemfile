source 'https://rubygems.org'

# Added Gems
gem 'sufia', '~> 7.2'
gem 'flipflop', github: 'jcoyne/flipflop', branch: 'hydra'

# EZID client from Duke
gem 'ezid-client'
# LDAP client
gem 'net-ldap'
# Webserver
gem 'puma'
# Date range support
gem 'edtf'
# Use mysql as the database for Active Record
gem 'mysql2'

gem 'config'

# Gems added by generator
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'
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
gem 'resque-web', '~> 0.0.7', require: 'resque_web'
gem 'resque'
gem 'resque-pool'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc


group :production do
  # Only try to run virus scan in production
  gem 'clamav'
end

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
end

group :development do
  gem 'engine_cart'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'ffaker'
end

gem 'rsolr', '~> 1.0.6'
gem 'devise'
gem 'devise-guests', '~> 0.3'

