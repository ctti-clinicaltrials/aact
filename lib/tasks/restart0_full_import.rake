namespace :import do
  namespace :restart0 do
    task :run, [:force] => :environment do |t, params|
      # Restart full load.  Load only studies with NCT IDs that end with 0
      ClinicalTrials::Updater.new({:event_type=>'full', :restart=>true,:study_filter=>'0'}).run
    end
  end
end
