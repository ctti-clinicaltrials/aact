namespace :import do
  namespace :restart9 do
    task :run, [:force] => :environment do |t, params|
      # Restart full load.  Load only studies with NCT IDs that end with 9
      ClinicalTrials::Updater.new({:event_type=>'full', :restart=>true,:study_filter=>'9'}).run
    end
  end
end
