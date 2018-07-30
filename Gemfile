source "https://rubygems.org"

ruby "2.4.0"

gem 'nokogiri', '~> 1.8.1'
gem 'rails', github: 'rails/rails', branch: '4-2-stable'
gem 'rails-html-sanitizer', '~> 1.0.4'
gem "rack-timeout"
gem "faraday"
gem "autoprefixer-rails"
gem "flutie"
gem "high_voltage"
gem "jquery-rails"
gem "sidekiq"
gem "normalize-rails"
gem "pg"
gem 'rails_12factor'
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
gem 'font-awesome-rails'
gem 'roo', '~> 2.4.0'
gem 'string-similarity'
gem 'gon'
gem 'execjs'
gem 'therubyracer', '~> 0.12.3'
gem 'libv8', '~> 3.16.14.15'
gem 'rack'
gem 'rack-cors', :require => 'rack/cors'
gem 'rack-protection', '~> 1.5.5'
gem 'loofah', '~> 2.2.1'

# user registration
gem 'devise'
gem 'devise-encryptable'

# deployment to server
gem 'capistrano', '~> 3.8'
gem 'capistrano-rails', '~> 1.2'

group :development do
  gem "quiet_assets"
#  gem "spring"
#  gem "spring-commands-rspec"
  gem 'letter_opener'
end

group :development, :test do
  gem "rack-mini-profiler", require: false
  gem "awesome_print"
  gem "bullet"
  gem "bundler-audit", ">= 0.5.0", require: false
  gem "factory_girl_rails"
  gem "pry-byebug"
  gem "pry-rails"
  gem 'rspec-rails'
  gem 'single_test'
end

group :test do
  gem "database_cleaner"
  gem 'capybara'
  gem "capybara-webkit"
  gem 'selenium-webdriver' # For Firefox
  gem 'chromedriver-helper'
  gem "formulaic"
  gem "launchy"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "timecop"
  gem "webmock"
  gem "vcr"
end
