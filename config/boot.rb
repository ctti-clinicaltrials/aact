ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

if ENV['DOCKER']
  require 'rails/commands/server'

  module Rails
    class Server
      alias :default_options_bk :default_options
      def default_options
        default_options_bk.merge!(Host: '0.0.0.0')
      end
    end
  end
end
