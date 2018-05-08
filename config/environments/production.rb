Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.middleware.use Rack::Deflater
  config.assets.js_compressor = :uglifier
  config.assets.digest = true
  config.log_level = :debug
  config.assets.precompile =  ['*.js', '*.css', '*.scss']
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings =  {
    :address => '127.0.0.1',
    :port    => '25',
    :domain  => ENV.fetch("APPLICATION_HOST")
  }
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  config.active_record.dump_schema_after_migration = false
  config.action_mailer.default_url_options = { host: ENV.fetch("APPLICATION_HOST") }
end
Rack::Timeout.timeout = (ENV["RACK_TIMEOUT"] || 10).to_i
