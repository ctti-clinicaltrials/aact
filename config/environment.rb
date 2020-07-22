# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!
# force Rails into production mode
# We don't control web/app server & can't set it that way
ENV['RAILS_ENV'] ||= 'production'
