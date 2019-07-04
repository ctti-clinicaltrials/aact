require File.expand_path('../boot', __FILE__)
require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require 'zip'
require 'csv'

Bundler.require(*Rails.groups)
module AACT
  class Application < Rails::Application
    config.time_zone = 'Eastern Time (US & Canada)'
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
    config.active_record.raise_in_transactional_callbacks = true

    AACT_DB_SUPER_USERNAME = ENV['AACT_DB_SUPER_USERNAME'] || 'ctti'   # Name of postgres user that has permission to update the database
    AACT_OWNER_EMAIL       = ENV['AACT_OWNER_EMAIL']                   # Don't define this if your email service is not setup
    AACT_ADMIN_EMAILS      = ENV['AACT_ADMIN_EMAILS'] || "aact@your-org.org,admin@your-org.org" # Identifes who will receive load notifications
    AACT_STATIC_FILE_DIR   = ENV['AACT_STATIC_FILE_DIR'] || '/aact-files'  # directory containing AACT static files such as the downloadable db snapshots
    RACK_TIMEOUT           = ENV['RACK_TIMEOUT'] || 10

    if Rails.env != 'test'
      APPLICATION_HOST          = ENV['APPLICATION_HOST'] || 'localhost'           # Server on which database loads run
      AACT_PUBLIC_HOSTNAME      = ENV['AACT_PUBLIC_HOSTNAME'] || 'localhost'       # Server on which the publicly accessible database resides
      AACT_BACK_DATABASE_NAME   = ENV['AACT_BACK_DATABASE_NAME'] || 'aact_back'    # Name of background database used to process loads
      AACT_ADMIN_DATABASE_NAME  = ENV['AACT_ADMIN_DATABASE_NAME'] || 'aact_admin'  # Name of database used to support the AACT website
      AACT_PUBLIC_DATABASE_NAME = ENV['AACT_PUBLIC_DATABASE_NAME'] || 'aact'       # Name of database available to the public
      AACT_ALT_PUBLIC_DATABASE_NAME = ENV['AACT_ALT_PUBLIC_DATABASE_NAME'] || 'aact_alt'  # Name of alternate database available to the public
    else
      APPLICATION_HOST          = 'localhost'
      AACT_PUBLIC_HOSTNAME      = 'localhost'
      AACT_BACK_DATABASE_NAME   = 'aact_back_test'
      AACT_ADMIN_DATABASE_NAME  = 'aact_admin_test'
      AACT_PUBLIC_DATABASE_NAME = 'aact_test'
      AACT_ALT_PUBLIC_DATABASE_NAME = 'aact_alt_test'
    end
    AACT_BACK_DATABASE_URL       = "postgres://#{AACT_DB_SUPER_USERNAME}@#{APPLICATION_HOST}:5432/#{AACT_BACK_DATABASE_NAME}"
    AACT_ADMIN_DATABASE_URL      = "postgres://#{AACT_DB_SUPER_USERNAME}@#{APPLICATION_HOST}:5432/#{AACT_ADMIN_DATABASE_NAME}"
    AACT_PUBLIC_DATABASE_URL     = "postgres://#{AACT_DB_SUPER_USERNAME}@#{AACT_PUBLIC_HOSTNAME}:5432/#{AACT_PUBLIC_DATABASE_NAME}"
    AACT_ALT_PUBLIC_DATABASE_URL = "postgres://#{AACT_DB_SUPER_USERNAME}@#{AACT_PUBLIC_HOSTNAME}:5432/#{AACT_ALT_PUBLIC_DATABASE_NAME}"

    #CORS
    cors_origins = '*'
    cors_origins = ENV['CORS_ORIGINS'].split(',') if ENV['CORS_ORIGINS']

    config.middleware.insert_before 0, "Rack::Cors", :debug => true, :logger => (-> { Rails.logger }) do
      allow do
        origins cors_origins

        resource '*',
          :headers => :any,
          :methods => [:get, :post, :delete, :put, :options, :head],
          :max_age => 0
      end
    end
  end
end
