# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks
task(:default).clear
task default: [:spec]

namespace :db do
  def set_search_path
    puts "Setting search path to ctgov..."
    con=ActiveRecord::Base.connection
    con.execute("create schema ctgov;")
    con.execute("alter role ctti set search_path to ctgov, public;")
    con.execute("grant usage on schema ctgov to ctti;")
    con.execute("grant create on schema ctgov to ctti;")
    con.reset!
  end

  task :before_set_search_path do
    before { set_search_path }
  end

  task :after_set_search_path do
    at_exit { set_search_path }
  end

end

Rake::Task['db:create'].enhance(['db:after_set_search_path'])


if Rails.env != 'production'
  begin
    task(:spec).clear
    RSpec::Core::RakeTask.new(:spec) do |t|
      t.verbose = false
    end
  rescue
  end
end

task default: "bundler:audit"
