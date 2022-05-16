require_relative 'boot'

require 'rails/all'
require 'zip'
require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AACT
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
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

    # Note:  You must define the AACT DB superuser's password in the .pgpass file that needs to be in the root directory of the user who runs
    # the rails app.  We don't save passwords in Env Vars because they can be to easily exposed that way.
    AACT_DB_SUPER_USERNAME = ENV['AACT_DB_SUPER_USERNAME'] || 'aact'   # Name of postgres superuser that has permission to create a database.
    AACT_OWNER_EMAIL       = ENV['AACT_OWNER_EMAIL']                   # Don't define this if your email service is not setup
    AACT_ADMIN_EMAILS      = ENV['AACT_ADMIN_EMAILS'] || "aact@your-org.org,admin@your-org.org" # Identifes who will receive load notifications
    AACT_STATIC_FILE_DIR   = ENV['AACT_STATIC_FILE_DIR'] || '~/aact-files'  # directory containing AACT static files such as the downloadable db snapshots

    APPLICATION_HOST          = 'localhost'
    AACT_HOST = ENV['AACT_HOST'] || 'localhost'
    if Rails.env != 'test'
      AACT_PUBLIC_HOSTNAME      =  ENV['AACT_PUBLIC_HOSTNAME'] || 'localhost'#Server on which the publicly accessible database resides
      AACT_BACK_DATABASE_NAME   =  ENV['AACT_BACK_DATABASE_NAME']|| 'aact'    # Name of background database used to process loads
      AACT_ADMIN_DATABASE_NAME  =  ENV['AACT_ADMIN_DATABASE_NAME'] || 'aact_admin' # Name of database used to support the AACT website
      AACT_PUBLIC_DATABASE_NAME =  ENV['AACT_PUBLIC_DATABASE_NAME'] || 'aact'  # Name of database available to the public
      AACT_ALT_PUBLIC_DATABASE_NAME = ENV['AACT_ALT_PUBLIC_DATABASE_NAME'] || 'aact_alt' # Name of alternate database available to the public
    else
      AACT_PUBLIC_HOSTNAME      = 'localhost'
      AACT_BACK_DATABASE_NAME   = 'aact_test'
      AACT_ADMIN_DATABASE_NAME  = 'aact_admin_test'
      AACT_PUBLIC_DATABASE_NAME = 'aact_test'
      AACT_ALT_PUBLIC_DATABASE_NAME = 'aact_alt_test'
    end
    AACT_PORT = ENV['AACT_PORT'] || 5432
    AACT_PASS = ENV['AACT_PASSWORD'] || ''
    AACT_BACK_DATABASE_URL       = "postgres://#{AACT_DB_SUPER_USERNAME}:#{AACT_PASS}@#{AACT_HOST}:#{AACT_PORT}/#{AACT_BACK_DATABASE_NAME}"
    AACT_ADMIN_DATABASE_URL      = "postgres://#{AACT_DB_SUPER_USERNAME}:#{AACT_PASS}@#{AACT_HOST}:5432/#{AACT_ADMIN_DATABASE_NAME}"
    AACT_PUBLIC_DATABASE_URL     = "postgres://#{AACT_DB_SUPER_USERNAME}@#{AACT_PUBLIC_HOSTNAME}:5432/#{AACT_PUBLIC_DATABASE_NAME}"
    AACT_ALT_PUBLIC_DATABASE_URL = "postgres://#{AACT_DB_SUPER_USERNAME}@#{AACT_PUBLIC_HOSTNAME}:5432/#{AACT_ALT_PUBLIC_DATABASE_NAME}"
    # If you deploy to a server, you need the following env variables defined for capistrano:
    # AACT_DEPLOY_TO
    AACT_PROD_REPO_URL="git@github.com:ctti-clinicaltrials/aact.git"
    AACT_PROD_SERVER="ctti-web-01.oit.duke.edu"
    AACT_DEV_REPO_URL="git@github.com:tibbs001/aact-1.git"
    AACT_DEV_SERVER="ctti-web-dev-01.oit.duke.edu"
    AACT_SERVER_USERNAME="ctti-aact"
    #AACT_SSH_KEY_DIR="/#{AACT_SERVER_USER}/.ssh/id_rsa"

    #Also create directory: /aact-files (either at system root or in home directory) and set AACT_STATIC_FILE_DIR to that directory.
    #Under it, create sub directories:  documentation, logs, tmp

    #CORS
    cors_origins = '*'
    cors_origins = ENV['CORS_ORIGINS'].split(',') if ENV['CORS_ORIGINS']

    config.middleware.insert_before 0, Rack::Cors, :debug => true, :logger => (-> { Rails.logger }) do
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
