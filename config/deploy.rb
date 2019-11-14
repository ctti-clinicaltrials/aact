# config valid only for current version of Capistrano
lock "3.8.2"
set :chruby_ruby, 'ruby-2.4.5'

set :application, "aact"

# Default branch is :master
ask :branch, 'development'
set :rails_env, 'development'

namespace :deploy do
  after :deploy, 'finish_up'
end

desc 'Finalize the deployment'
task :finish_up do
  on roles(:app) do
    # create symlink to to the root directory containing aact static files
    # content of this directory can get big; we create this directory on a separate NAS drive
    source = ENV.fetch('AACT_STATIC_FILE_DIR','~/aact-files')
    target = release_path.join('public/static')
    begin
      execute :ln, '-s', source, target
    rescue
      # Don't fail if the source directory doesn't exist.
      # the Util::FileManager will initialize public/static if necessary
    end
  end
end

# Default deploy_to directory is /var/www/my_app_name

# Default value for :format is :airbrussh.
#set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
set :format_options, command_output: true, log_file: "#{ENV.fetch('STATIC_FILE_DIR','~/aact-files')}/logs/capistrano_aact.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}

set :default_env, {
  'PATH' => ENV['AACT_PATH'] || "<server-path>/shared/bundle/ruby/2.4.5/bin:/opt/rh/rh-ruby24/root/usr/lib64",
  'LD_LIBRARY_PATH' => ENV['LD_LIBRARY_PATH'] || "/opt/rh/rh-ruby24/root/usr/lib64",
  'APPLICATION_HOST' => ENV['APPLICATION_HOST'] || 'localhost',
  'AACT_STATIC_FILE_DIR' => ENV['AACT_STATIC_FILE_DIR'] || '~/aact-files',
  'RUBY_VERSION' =>  ENV['RUBY_VERSION'] || 'ruby 2.4.5',
  'GEM_HOME' => ENV['GEM_HOME'] || '~/.gem/ruby',
  'GEM_PATH' => ENV['GEM_PATH'] || '~/.gem/ruby/gems:/opt/rh/rh-ruby24/root/usr/share/gems:/opt/rh/rh-ruby24/root/usr/local/share/gems:/opt/rh/rh-ruby24/root/usr/lib64'
}

# Default value for keep_releases is 5
 set :keep_releases, 5
#
