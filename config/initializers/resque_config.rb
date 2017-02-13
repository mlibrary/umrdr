require 'resque'
config = YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redis.yml'))).result)[Rails.env].with_indifferent_access
Resque.redis = Redis.new(host: config[:host], port: config[:port], thread_safe: true)

Resque.inline = Rails.env.test?

# The redis_namespace should be being set in the umrdr-deploytment file
# upload/XXX-config/settings/production.yml
#
# Both these need to be set, at least in our version of sufia. The former
# is being used in one place...somewhere...while the latter is used
# everywhere else.

config.redis_namespace = Settings.redis_namespace || 'umrdr_stupid_unconfigured_namespace'
Resque.redis.namespace = Settings.redis_namespace || 'umrdr_stupid_unconfigured_namespace'

