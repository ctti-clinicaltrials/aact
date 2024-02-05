source "https://rubygems.org"

ruby "2.7.7"

gem "sprockets"
gem "rubyzip", ">= 1.2.2"

gem 'inky-rb', require: 'inky'
gem 'haml'
gem 'premailer-rails'
gem 'foundation_emails'

gem 'nokogiri'
gem 'loofah'
gem 'rails', '6.0.0'
gem 'activesupport', '6.0.0'
gem 'actionpack', '6.0.0'
gem 'rails-html-sanitizer'
gem "rack-timeout"
gem "faraday"
gem "autoprefixer-rails"
gem "flutie"
gem "high_voltage"
gem "jquery-rails"
gem "normalize-rails"
gem "pg", '~> 0.18'
# gem 'rails_12factor'
gem "coderay"
gem "recipient_interceptor"
gem 'rest-client'
gem 'enumerize'
gem 'activerecord-import', '>= 1.4.1' #for some reason more updated versions slow down the loads
gem 'sinatra', :require => nil
gem 'colorize'
gem 'font-awesome-rails'
gem 'roo'
gem 'string-similarity'
gem 'gon'
gem 'execjs'
gem 'rack'
gem 'rack-cors', :require => 'rack/cors'
gem 'rack-protection', '~> 2.2.2'
gem 'caxlsx'
gem 'airbrake'
gem 'parallel'
gem 'ruby-progressbar'
gem "aws-sdk-s3", require: false

# deployment to server
gem 'capistrano', '~> 3.8'
gem 'capistrano-rails', '~> 1.2'
#gem 'capistrano-chruby'

group :development do
  # gem "quiet_assets"
  gem 'letter_opener'
end

group :development, :test do
  gem "rack-mini-profiler", require: false
  gem "awesome_print"
  gem "bullet"
  gem "factory_bot_rails"
  gem "pry-byebug"
  gem "pry-rails"
  gem 'rspec-rails'
  gem 'single_test'
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :test do
  gem "database_cleaner", "1.8.5"
  gem "formulaic"
  gem "launchy"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "timecop"
  gem "webmock"
  gem "vcr"
end