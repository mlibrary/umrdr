Sufia.config do |config|
  config.fits_to_desc_mapping = {
    file_title: :title,
    file_author: :creator
  }

  config.max_days_between_audits = 7

  config.max_notifications_for_dashboard = 5

  config.resource_types = { "Dataset" => "Dataset" }
  # TODO move to resource types service and QA after sufia 7.0
  config.resource_types_to_schema = {"Dataset" => "http://schema.org/Dataset"}


  config.permission_levels = {
    "Choose Access" => "none",
    "View/Download" => "read",
    "Edit" => "edit"
  }

  config.owner_permission_levels = {
    "Edit" => "edit"
  }

  # Enable displaying usage statistics in the UI
  # Defaults to FALSE
  # Requires a Google Analytics id and OAuth2 keyfile.  See README for more info
  config.analytics = false

  # Specify a Google Analytics tracking ID to gather usage statistics
  # config.google_analytics_id = 'UA-99999999-1'

  # Specify a date you wish to start collecting Google Analytic statistics for.
  # config.analytic_start_date = DateTime.new(2014,9,10)

  # Enables a link to the citations page for a generic_file.
  # Default is false
  # config.citations = false

  # Enables a link to the citations page for a generic_file.
# Default is false
# config.citations = false
# Where to store tempfiles, leave blank for the system temp directory (e.g. /tmp)
  # config.temp_file_base = '/home/developer1'

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
  # config.minter_statefile = '/tmp/minter-state'
  config.minter_statefile = ENV['MINTER_FILE'] || "/tmp/umrdr-minter-#{Time.now.min}#{Time.now.sec}"


  # Process for translating Fedora URIs to identifiers and vice versa
  # config.translate_uri_to_id = ActiveFedora::Noid.config.translate_uri_to_id
  # config.translate_id_to_uri = ActiveFedora::Noid.config.translate_id_to_uri

  # Specify the prefix for Redis keys:
  # config.redis_namespace = "sufia"
  #config.redis_namespace = ENV['REDIS_NS'] || "umrdr"

  # Specify the path to the file characterization tool:
  config.fits_path = system("which", "fits.sh") ? "fits.sh" : "/l/local/fits/fits.sh"

  # Specify how many seconds back from the current time that we should show by default of the user's activity on the user's dashboard
  # config.activity_to_show_default_seconds_since_now = 24*60*60

  # Sufia can integrate with Zotero's Arkivo service for automatic deposit
  # of Zotero-managed research items.
  # config.arkivo_api = false

  # Specify a date you wish to start collecting Google Analytic statistics for.
  # Leaving it blank will set the start date to when ever the file was uploaded by
  # NOTE: if you have always sent analytics to GA for downloads and page views leave this commented out
  # config.analytic_start_date = DateTime.new(2014,9,10)

  #contact form email addresses
  config.contact_email = Rails.env.production? ? 'deepblue@umich.edu' : "#{ENV['USER']}@umich.edu"
  config.notification_email = Rails.env.production? ? 'researchdataservices@umich.edu' : "#{ENV['USER']}@umich.edu"
  config.from_email  = 'deepblue@umich.edu'

  config.geonames_username = ''

  config.max_file_size = 2 * ( 1024 ** 3 )
  config.max_file_size_str = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert(config.max_file_size, {})

  config.max_total_file_size = config.max_file_size * 5
  config.max_total_file_size_str = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert(config.max_total_file_size, {})

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
