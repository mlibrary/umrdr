Sufia.config do |config|

  config.arkivo_api = false

  config.max_days_between_audits = 7

  config.max_notifications_for_dashboard = 5
  config.register_curation_concern :generic_work
  # Injected via `rails g sufia:work DeepBlueWork`
  config.register_curation_concern :deep_blue_work

  config.permission_levels = {
    "Choose Access" => "none",
    "View/Download" => "read",
    "Edit" => "edit"
  }

  config.owner_permission_levels = {
    "Edit" => "edit"
  }

  # disable link for download image and download one file for a work
  config.display_media_download_link = false
  # Enable displaying usage statistics in the UI
  # Defaults to FALSE
  # Requires a Google Analytics id and OAuth2 keyfile.  See README for more info
  config.analytics = true

  # Specify a Google Analytics tracking ID to gather usage statistics
  config.google_analytics_id = Rails.application.secrets.analytics_id

  # Specify a date you wish to start collecting Google Analytic statistics for.
  config.analytic_start_date = DateTime.new(2016,4,10)

  # Enables a link to the citations page for a generic_file.
  # Default is false
  # config.citations = false

  # Enables a link to the citations page for a generic_file.
# Default is false
# config.citations = false


  # Where to store tempfiles, leave blank for the system temp directory (e.g. /tmp)
  # Used by Hydra::Derivities / fits
   config.temp_file_base = File.join(Rails.root, 'tmp', 'derivatives')

  # Specify the form of hostpath to be used in Endnote exports
  # config.persistent_hostpath = 'http://localhost/files/'

  # If you have ffmpeg installed and want to transcode audio and video uncomment this line
  # config.enable_ffmpeg = true

  # Sufia uses NOIDs for files and collections instead of Fedora UUIDs
  # where NOID = 10-character string and UUID = 32-character string w/ hyphens
  # config.enable_noids = true

  # Specify a different template for your repository's NOID IDs
  # config.noid_template = ".reeddeeddk"

  # Store identifier minter's state in a file for later replayability
  # Settings read per environment from config/settings.rb and config/settings/<env>.yml
  config.minter_statefile = Settings.minter_file

  # Process for translating Fedora URIs to identifiers and vice versa
  # config.translate_uri_to_id = ActiveFedora::Noid.config.translate_uri_to_id
  # config.translate_id_to_uri = ActiveFedora::Noid.config.translate_id_to_uri

  # Specify the prefix for Redis keys:
  config.redis_namespace = Settings.redis_namespace

  # Specify the path to the file characterization tool:
  config.fits_path = system("which", "fits.sh") ? "fits.sh" : "/l/local/fits/fits.sh"

  # Specify how many seconds back from the current time that we should show by default of the user's activity on the user's dashboard
  # config.activity_to_show_default_seconds_since_now = 24*60*60

  # Sufia can integrate with Zotero's Arkivo service for automatic deposit
  # of Zotero-managed research items.
  # config.arkivo_api = false

  # Contact form email
  config.contact_email = Settings.contact_email
  
  config.geonames_username = ''

  #This enables or disables the ability to download files.
  config.define_singleton_method(:download_files) do
    return true
  end

  #config.max_file_size = 2 * ( 1024 ** 3 )
  #config.max_file_size_str = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert(config.max_file_size, {})

  #config.max_total_file_size = config.max_file_size * 5
  #config.max_total_file_size_str = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert(config.max_total_file_size, {})

  # If browse-everything has been configured, load the configs.  Otherwise, set to nil.
  begin
    if defined? BrowseEverything
      config.browse_everything = BrowseEverything.config
    else
      Rails.logger.warn "BrowseEverything is not installed"
    end
  rescue Errno::ENOENT
    config.browse_everything = nil
  end
end

Date::DATE_FORMATS[:standard] = '%Y-%m-%d'
