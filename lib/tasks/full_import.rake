namespace :import do
  namespace :full do
    task :run, [:force] => :environment do |t, args|
      ClinicalTrials::Updater.new({:event_type=>'full'}).run
    end
  end
end
