namespace :trial do
  task :run, [:force] => :environment do |t, params|
    ClinicalTrials::Updater.trial_run
  end
end
