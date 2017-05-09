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

    #sidekiq
    #config.active_job.queue_adapter = :sidekiq

    # deposit notification email addresses
    config.notification_email = Settings.notification_email

    config.max_file_size = 2 * ( 1024 ** 3 )
    config.max_file_size_str = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert(config.max_file_size, {})

    config.max_total_file_size = config.max_file_size * 5
    config.max_total_file_size_str = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert(config.max_total_file_size, {})

    # Deploy to /data instead of /
    config.relative_url_root = '/data'

    # For properly generating URLs and minting DOIs - the app may not by default
    # Outside of a request context the hostname needs to be provided.
    config.hostname = ENV['UMRDR_HOST'] || Settings.umrdr_host

    # Set the default host for resolving _url methods
    Rails.application.routes.default_url_options[:host] = config.hostname

    # URL for logging the user out of Cosign
    config.logout_prefix = "https://weblogin.umich.edu/cgi-bin/logout?"
    
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

    require 'tinymce/rails/asset_installer/copy'
    class CopyNoPreserve < TinyMCE::Rails::AssetInstaller::Copy
      def copy_assets
        logger.info "Copying assets (without mode preservation) to #{File.join(target, "tinymce")}"
        FileUtils.cp_r(assets, target)
      end
    end

    config.tinymce.install = CopyNoPreserve
  end
end
