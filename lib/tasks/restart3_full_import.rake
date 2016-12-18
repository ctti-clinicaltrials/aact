namespace :import do
  namespace :restart3 do
    task :run, [:force] => :environment do |t, params|
      # Restart full load.  Load only studies with NCT IDs that end with 3
      ClinicalTrials::Updater.new({:event_type=>'full', :restart=>true,:study_filter=>'3'}).run
    end
  end
end
