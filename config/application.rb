require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Umrdr
  class Application < Rails::Application
    
    config.generators do |g|
      g.test_framework :rspec, :spec => true
    end

    # Deploy to /data instead of /
    config.relative_url_root = '/data'

    # Cosign configuration
    config.hostname = 'umrdr-testing.quod.lib.umich.edu'
    config.cosign_host = 'weblogin.umich.edu'
    config.cosign_service = "cosign-#{config.hostname}"
    config.cosign_login_redirect = "https://#{config.hostname}/data/dashboard"
    config.cosign_logout_redirect = "https://#{config.hostname}/data"
    config.login_url = "https://#{config.cosign_host}/?#{config.cosign_service}&#{config.cosign_login_redirect}"
    config.logout_url = "https://#{config.cosign_host}/cgi-bin/logout?#{config.cosign_logout_redirect}"
    
    # Set the default host for resolving _url methods
    Rails.application.routes.default_url_options[:host] = config.hostname

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Additional directories with ruby to be autoloaded
    config.autoload_paths += Dir["#{config.root}/lib/**/*"]
  end
end
