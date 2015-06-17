source 'https://rubygems.org'

# Sufia & kaminari patch
gem 'sufia', github: 'projecthydra/sufia', branch: 'pcdm'
gem 'kaminari', github: 'jcoyne/kaminari', branch: 'sufia'

# UMichwrapper
group :development, :alpha do
  gem 'umichwrapper', github: 'mlibrary/umichwrapper', branch: 'finer_control'
end

# Webserver
gem 'puma'

# sufia pcdm required
gem 'hydra-works', github: 'projecthydra-labs/hydra-works', branch: 'master'
gem 'rdf-vocab'

# from engine cart
gem 'hydra-derivatives', github: 'projecthydra/hydra-derivatives', ref: '13df67f'

gem 'active-fedora', github: 'projecthydra/active_fedora', ref:'57ac754'
gem 'activefedora-aggregation', github: 'projecthydra-labs/activefedora-aggregation', ref: 'eef02b0'
gem 'hydra-pcdm', github: 'projecthydra-labs/hydra-pcdm', ref: 'c8a4654'

gem 'active-triples'
gem 'active_fedora-noid', github: 'projecthydra-labs/active_fedora-noid', ref: '38079e4'

gem 'hydra-collections', github: 'projecthydra/hydra-collections', ref: '486ed3b'


# Preemptively require gems so that rails generate hydra:install will complete.
#   This is a vendorized gems issue with Bundle.with_clean_env
gem 'orm_adapter'
gem 'responders'
gem 'warden'
gem 'devise'
gem 'devise-guests', '~> 0.3'
gem 'bcrypt'
gem 'thread_safe'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'rsolr', '~> 1.0.6'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'rspec-rails'
  gem 'jettywrapper'
end

group :migrations, :alpha, :production do
  # Use mysql in production
  gem 'mysql2'
end

