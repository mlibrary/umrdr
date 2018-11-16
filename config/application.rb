require File.expand_path('../boot', __FILE__)

require 'rails/all'
require_relative '../lib/rack_multipart_buf_size_setter.rb'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Umrdr

  class Application < Rails::Application

    config.generators do |g|
      g.test_framework :rspec, :spec => true
    end

    config.middleware.insert_before Rack::Runtime, RackMultipartBufSizeSetter

    config.dbd_version = 'DBDv1'
    # config.dbd_version = 'DBDv2'

    ## configure box

    config.box_enabled = false
    config.box_developer_token = nil # replace this with a developer token to override Single Auth
    #config.box_developer_token = 'IGmQMmqw8coKpuQDN3EG4gBrDzn78sGr'.freeze
    config.box_dlib_dbd_box_user_id = '3200925346'.freeze
    config.box_ulib_dbd_box_id = '45101723215'.freeze
    config.box_verbose = true
    config.box_always_report_not_logged_in_errors = true
    config.box_create_dirs_for_empty_works = true
    config.box_access_and_refresh_token_file = File.join( Rails.root, 'config', 'box_config.yml' ).freeze
    config.box_access_and_refresh_token_file_init = File.join( Rails.root, 'config', 'box_config_init.yml' ).freeze
    config.box_integration_enabled = config.box_enabled && ( !config.box_developer_token.nil? ||
                                                            File.exist?( config.box_access_and_refresh_token_file ) )

    ## configure for Globus
    # -- To enable Globus for development, create /deepbluedata-globus/download and /deepbluedata-globus/prep
    config.globus_era_timestamp = Time.now.freeze
    config.globus_era_token = config.globus_era_timestamp.to_s.freeze
    if Rails.env.test?
      config.globus_dir = '/tmp/deepbluedata-globus'
      Dir.mkdir config.globus_dir unless Dir.exist? config.globus_dir
    else
      config.globus_dir = ENV['GLOBUS_DIR'] || '/deepbluedata-globus'
    end
    #puts "globus_dir=#{config.globus_dir}"
    config.globus_dir = Pathname.new config.globus_dir
    config.globus_download_dir = config.globus_dir.join 'download'
    config.globus_prep_dir = config.globus_dir.join 'prep'
    if Rails.env.test?
      Dir.mkdir config.globus_download_dir unless Dir.exist? config.globus_download_dir
      Dir.mkdir config.globus_prep_dir unless Dir.exist? config.globus_prep_dir
    end
    config.globus_enabled = true && Dir.exist?( config.globus_download_dir ) && Dir.exist?( config.globus_prep_dir )
    config.base_file_name = "DeepBlueData_"
    config.globus_base_url = 'https://www.globus.org/app/transfer?origin_id=99d8c648-a9ff-11e7-aedd-22000a92523b&origin_path=%2Fdownload%2F'
    config.globus_log_provenance_copy_job_complete = false
    config.globus_restart_all_copy_jobs_quiet = true
    config.globus_debug_delay_per_file_copy_job_seconds = 0
    config.globus_after_copy_job_ui_delay_seconds = 3

    # if config.globus_enabled
    #   config.globus_era = Umrdr::GlobusEra.instance
    #   #config.globus_era_file = GlobusEra.instance.era_file
    # end

    # deposit notification email addresses
    config.notification_email = Settings.notification_email
    config.user_email = Settings.user_email    
    
    config.max_file_size = 2 * ( 1024 ** 3 )
    config.max_file_size_str = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert(config.max_file_size, {})

    config.max_total_file_size = config.max_file_size * 5
    config.max_total_file_size_str = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert(config.max_total_file_size, {})

    config.max_work_file_size_to_download = 10_000_000_000
    config.min_work_file_size_to_download_warn = 1_000_000_000

    # ingest characterization config
    config.characterize_excluded_ext_set = { '.csv' => 'text/plain' }.freeze #, '.nc' => 'text/plain' }.freeze

    # ingest derivative config
    config.derivative_excluded_ext_set = {}.freeze
    config.derivative_max_file_size = 4_000_000_000 # set to -1 for no limit
    config.derivative_max_file_size_str = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert(config.derivative_max_file_size, precision: 3 )

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

    config.do_ordered_list_hack = true
    config.do_ordered_list_hack_save = true

    config.skylight.probes -= ['middleware']
  end
end
