namespace :trial do
  task :run, [:force] => :environment do |t, params|
    Util::Updater.trial_run
  end
end
