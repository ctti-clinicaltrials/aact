source "https://rubygems.org"

ruby "2.4.0"

gem 'libv8', '3.16.14.3'
gem 'nokogiri'
gem 'faraday_middleware-aws-signers-v4'
gem 'rails', github: 'rails/rails', branch: '4-2-stable'
gem "rack-timeout"
gem "faraday"
gem "autoprefixer-rails"
gem "flutie"
gem "high_voltage"
gem "jquery-rails"
gem 'appsignal', '~> 2.3'
gem "sidekiq"
gem "normalize-rails"
gem "pg"
gem 'rails_12factor'
gem "puma"
gem "coderay"
gem "recipient_interceptor"
gem "sass-rails"
gem "sprockets-rails",'>= 2.0'
gem "title"
gem "uglifier"
gem "jbuilder"
gem "rails-erd"
gem 'rest-client'
gem 'enumerize'
gem 'bulk_insert'
gem 'activerecord-import'
gem 'sinatra', :require => nil
gem 'font-awesome-sass'
gem 'roo', '~> 2.4.0'
gem 'string-similarity'
gem 'gon'

# user registration
gem 'devise'
gem 'devise-encryptable'

# Grape API
gem 'rack'
gem 'rack-cors', :require => 'rack/cors'

gem 'active_model_serializers', '~> 0.9.0'

group :development do
  gem 'capistrano', '~> 3.8'
  gem 'capistrano-rails', '~> 1.2'
  gem 'capistrano-chruby'
  gem "quiet_assets"
  gem "spring"
  gem "spring-commands-rspec"
  gem 'letter_opener'
end

group :development, :test do
  gem "awesome_print"
  gem "bullet"
  gem "bundler-audit", ">= 0.5.0", require: false
  gem "factory_girl_rails"
  gem "pry-byebug"
  gem "pry-rails"
  gem 'rspec-rails'
  gem 'single_test'
end

group :development, :staging do
  gem "rack-mini-profiler", require: false
end

group :test do
  gem "capybara-webkit"
  gem "database_cleaner"
  gem "formulaic"
  gem "launchy"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "timecop"
  gem "webmock"
  gem "vcr"
end
