Rails.application.configure do

  ENV["AACT_ADMIN_DATABASE_URL"] = 'postgres://localhost:5432/aact_admin_test'
  ENV["AACT_BACK_DATABASE_URL"] = 'postgres://localhost:5432/aact_back_test'
  config.assets.raise_runtime_errors = true
  config.cache_classes = true
  config.eager_load = false
  config.serve_static_files   = true
  config.static_cache_control = 'public, max-age=3600'
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = false
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.delivery_method = :test
  #config.action_mailer.raise_delivery_errors = false
  config.active_support.test_order = :random
  config.active_support.deprecation = :stderr
  config.action_view.raise_on_missing_translations = true
  config.action_mailer.default_url_options = { host: "www.example.com" }
  config.active_job.queue_adapter = :inline
end
