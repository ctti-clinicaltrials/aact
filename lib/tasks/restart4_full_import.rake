namespace :import do
  namespace :restart4 do
    task :run, [:force] => :environment do |t, params|
      # Restart full load.  Load only studies with NCT IDs that end with 4
      ClinicalTrials::Updater.new({:event_type=>'full', :restart=>true,:study_filter=>'4'}).run
    end
  end
end
