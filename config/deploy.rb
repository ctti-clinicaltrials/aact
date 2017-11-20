# config valid only for current version of Capistrano
lock "3.8.2"
#set :chruby_ruby, 'ruby-2.4.0'

set :application, "aact"
set :repo_url, "git@github.com:ctti-clinicaltrials/aact.git"

# Default branch is :master
ask :branch, 'development'
set :rails_env, 'development'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/srv/ctti/www/aact'

# Default value for :format is :airbrussh.
#set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}

set :default_env, {
#  'PATH' => "/path/to/.rvm/ree-1.8.7-2009.10/bin:/path/to/.rvm/gems/ree/1.8.7/bin:/path/to/.rvm/bin:$PATH",
  'RUBY_VERSION' => 'ruby 2.4.0',
  'GEM_HOME' => '/home/ctti-aact/.gem/ruby',
  'GEM_PATH' => '/home/ctti-aact/.gem/ruby:/opt/rh/rh-ruby24/root/usr/share/gems:/opt/rh/rh-ruby24/root/usr/local/share/gems'
}

# Default value for keep_releases is 5
 set :keep_releases, 5
#
