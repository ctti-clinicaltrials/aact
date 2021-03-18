Rails.application.configure do
  host = ENV.fetch('APPLICATION_HOST','localhost')
  config.cache_classes = true
  config.eager_load = false
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false
  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.middleware.use Rack::Deflater
  config.assets.js_compressor = :uglifier
  config.log_level = :debug
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings =  {
    address: ENV['EMAIL_SERVER'],
    port: ENV['EMAIL_PORT'],
    user_name: ENV['EMAIL_USERNAME'],
    password: ENV['EMAIL_PASSWORD'],
    authentication: 'plain',
    enable_starttls_auto: true
  }
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  config.active_record.dump_schema_after_migration = false
  config.action_mailer.default_url_options = { host: host }
end
Rack::Timeout.timeout = (ENV["RACK_TIMEOUT"] || 10).to_i
