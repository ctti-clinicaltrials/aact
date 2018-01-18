require File.expand_path('../application', __FILE__)
# force Rails into production mode
# We don't control web/app server & can't set it that way
ENV['RAILS_ENV'] ||= 'production'
Rails.application.initialize!
