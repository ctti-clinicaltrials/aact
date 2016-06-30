require File.expand_path('../boot', __FILE__)
require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require 'zip'

Bundler.require(*Rails.groups)
module Aact2
  class Application < Rails::Application
    config.quiet_assets = true
    config.generators do |generate|
      generate.helper false
      generate.javascript_engine false
      generate.request_specs false
      generate.routing_specs false
      generate.stylesheets false
      generate.test_framework :rspec
      generate.view_specs false
    end
    config.active_record.schema_format = :sql
    config.action_controller.action_on_unpermitted_parameters = :raise
    config.active_record.raise_in_transactional_callbacks = true
    config.active_job.queue_adapter = :sidekiq
    config.eager_load_paths += [
      "#{config.root}/app/workers",
      "#{config.root}/app/docs"
    ]
  end
end
