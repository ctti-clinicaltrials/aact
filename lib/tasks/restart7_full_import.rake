namespace :import do
  namespace :restart7 do
    task :run, [:force] => :environment do |t, params|
      # Restart full load.  Load only studies with NCT IDs that end with 7
      ClinicalTrials::Updater.new({:event_type=>'full', :restart=>true,:study_filter=>'7'}).run
    end
  end
end
