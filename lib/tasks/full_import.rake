namespace :import do
  namespace :full do
    task :run, [:force] => :environment do |t, params|
      if ![1].include? Date.today.day || args[:force]
        ClinicalTrials::Updater.new({:event_type='full'}).run
      end
    end
  end
end
