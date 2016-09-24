namespace :import do
  namespace :full do
    task :run, [:force] => :environment do |t, params|
      ClinicalTrials::Updater.full(params)
    end
  end
end
