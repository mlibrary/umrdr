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

    ## configure for Globus
    # -- To enable Globus for development, create /deepbluedata-globus/download and /deepbluedata-globus/prep
    if Rails.env.test?
      config.globus_dir = '/tmp/deepbluedata-globus'
      Dir.mkdir config.globus_dir unless Dir.exists? config.globus_dir
    else
      config.globus_dir = ENV['GLOBUS_DIR'] || '/deepbluedata-globus'
    end
    config.globus_dir = Pathname.new config.globus_dir
    config.globus_download_dir = config.globus_dir.join 'download'
    config.globus_prep_dir = config.globus_dir.join 'prep'
    if Rails.env.test?
      Dir.mkdir config.globus_download_dir unless Dir.exists? config.globus_download_dir
      Dir.mkdir config.globus_prep_dir unless Dir.exists? config.globus_prep_dir
    end
    config.globus_enabled = true && File.exists?( config.globus_download_dir ) && File.exists?( config.globus_prep_dir )
    config.base_file_name = "DeepBlueData_"
    config.globus_base_url = 'https://www.globus.org/app/transfer?origin_id=99d8c648-a9ff-11e7-aedd-22000a92523b&origin_path=%2Fdownload%2F'
    config.globus_era_file = Tempfile.new( 'globus_era_', ( config.globus_enabled ? config.globus_prep_dir : "." ) )

    # deposit notification email addresses
    config.notification_email = Settings.notification_email
    config.user_email = Settings.user_email    
    
    config.max_file_size = 2 * ( 1024 ** 3 )
    config.max_file_size_str = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert(config.max_file_size, {})

    config.max_total_file_size = config.max_file_size * 5
    config.max_total_file_size_str = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert(config.max_total_file_size, {})

    config.max_derivative_file_size = 4_000_000_000 # set to -1 for no limit
    config.max_derivative_file_size_str = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert( config.max_derivative_file_size, precision: 3 )

    # Deploy to /data instead of /
    config.relative_url_root = '/data' unless Rails.env.test?

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
