CurationConcerns.configure do |config|
  # Injected via `rails g curation_concerns:work GenericWork`
  config.register_curation_concern :generic_work

  #config.max_days_between_audits = 7

 # config.minter_statefile = ENV['MINTER_FILE'] || "/tmp/umrdr-minter-#{Time.now.min}#{Time.now.sec}"

  config.display_microdata = true
  config.microdata_default_type = 'http://schema.org/CreativeWork'

  # Enable displaying usage statistics in the UI
  # Defaults to FALSE
  # Requires a Google Analytics id and OAuth2 keyfile.  See README for more info
  #config.analytics = false

  # Specify a Google Analytics tracking ID to gather usage statistics
  # config.google_analytics_id = 'UA-99999999-1'

  # Specify a date you wish to start collecting Google Analytic statistics for.
  # config.analytic_start_date = DateTime.new(2014,9,10)

  # Where to store tempfiles, leave blank for the system temp directory (e.g. /tmp)
  # config.temp_file_base = '/home/developer1'

  # Specify the form of hostpath to be used in Endnote exports
  # config.persistent_hostpath = 'http://localhost/files/'

  # Location on local file system where derivatives will be stored.
  # config.derivatives_path = File.join(Rails.root, 'tmp', 'derivatives')

  # If you have ffmpeg installed and want to transcode audio and video uncomment this line
  # config.enable_ffmpeg = true

  # CurationConcerns uses NOIDs for files and collections instead of Fedora UUIDs
  # where NOID = 10-character string and UUID = 32-character string w/ hyphens
  # config.enable_noids = true

  # Specify a different template for your repository's NOID IDs
  # config.noid_template = ".reeddeeddk"

  # Store identifier minter's state in a file for later replayability
  # config.minter_statefile = '/tmp/minter-state'

  # Specify the prefix for Redis keys:
  #config.redis_namespace = ENV['REDIS_NS'] || "umrdr"

  # Specify the path to the file characterization tool:
  config.fits_path = system("which", "fits.sh") ? "fits.sh" : "/l/local/fits/fits.sh"

  # Specify a date you wish to start collecting Google Analytic statistics for.
  # Leaving it blank will set the start date to when ever the file was uploaded by
  # NOTE: if you have always sent analytics to GA for downloads and page views leave this commented out
  # config.analytic_start_date = DateTime.new(2014,9,10)
end

#Date::DATE_FORMATS[:standard] = '%Y-%m-%d'
