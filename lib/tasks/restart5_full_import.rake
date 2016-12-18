namespace :import do
  namespace :restart5 do
    task :run, [:force] => :environment do |t, params|
      # Restart full load.  Load only studies with NCT IDs that end with 5
      ClinicalTrials::Updater.new({:event_type=>'full', :restart=>true,:study_filter=>'5'}).run
    end
  end
end
