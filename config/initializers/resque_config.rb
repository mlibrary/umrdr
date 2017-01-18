require 'resque'
config = YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redis.yml'))).result)[Rails.env].with_indifferent_access
Resque.redis = Redis.new(host: config[:host], port: config[:port], thread_safe: true)

Resque.inline = Rails.env.test?

Resque.redis.namespace = ENV['REDIS_NS'] || 'umrdr_dev_of_some_kind'
Rails.logger.info "Rescue namespace is #{Resque.redis.namespace}"
Rails.logger.info "Rescue REDIS_NS environment variable is #{ENV['REDIS_NS']}"
