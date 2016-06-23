if Rails.env.development? || Rails.env.test? ||
  Rails.env.docker? || Rails.env.docker_test?
  require "bundler/audit/cli"

  namespace :bundler do
    desc "Updates the ruby-advisory-db and runs audit"
    task :audit do
      %w(update check).each do |command|
        Bundler::Audit::CLI.start [command]
      end
    end
  end
end
