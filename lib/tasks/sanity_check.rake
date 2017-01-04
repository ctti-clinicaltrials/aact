namespace :sanity_check do
  task run: :environment do
    ClinicalTrials::Updater.new.run_sanity_checks
  end
end
