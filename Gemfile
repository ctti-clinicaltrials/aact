source "https://rubygems.org"

ruby "2.4.1"

gem 'libv8', '3.16.14.3'
gem 'faraday_middleware-aws-signers-v4'
gem 'rails', github: 'rails/rails', branch: '4-2-stable'
gem "rack-timeout"
gem "faraday"
gem "autoprefixer-rails"
gem "flutie"
gem "high_voltage"
gem "jquery-rails"
gem "appsignal"
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
gem 'rubyzip'
gem 'enumerize'
gem 'bulk_insert'
gem 'activerecord-import'
gem 'sinatra', :require => nil
gem 'aws-sdk', '~> 2'
gem 'font-awesome-sass'
gem 'roo', '~> 2.4.0'
gem 'string-similarity'
gem 'gon'

gem 'fog'
#gem 'rmagick'
gem 'carrierwave'
gem 'mini_magick', '~> 4.3'

# Grape API
gem 'rack'
gem 'rack-cors', :require => 'rack/cors'

gem 'grape','>= 0.10.0'
gem 'grape-swagger'
gem 'kaminari'
gem 'grape-kaminari'
gem 'api-pagination'
gem "hashie-forbidden_attributes" #overrides strong_params in grape endpoints
gem 'active_model_serializers', '~> 0.9.0'
gem "grape-active_model_serializers"

gem 'elasticsearch-ruby'
gem 'elasticsearch-model', git: 'git://github.com/elasticsearch/elasticsearch-rails.git'
gem 'elasticsearch-rails', git: 'git://github.com/elasticsearch/elasticsearch-rails.git'

group :development, :docker do
  gem "quiet_assets"
  gem "spring"
  gem "spring-commands-rspec"
  gem 'letter_opener'
end

group :development, :test, :docker, :docker_test do
  gem "awesome_print"
  gem "bullet"
  gem "bundler-audit", ">= 0.5.0", require: false
  gem "factory_girl_rails"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rspec-rails", "~> 3.4.0"
end

group :development, :staging, :docker do
  gem "rack-mini-profiler", require: false
end

group :test, :docker_test do
#  gem "capybara-webkit"
  gem "database_cleaner"
  gem "formulaic"
  gem "launchy"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "timecop"
  gem "webmock"
  gem "vcr"
end
