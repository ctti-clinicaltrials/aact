namespace :import do
  namespace :restart do
    task :run, [:force] => :environment do |t, params|
      ClinicalTrials::Updater.new({:event_type=>'full'}).create_studies
    end
  end
end
