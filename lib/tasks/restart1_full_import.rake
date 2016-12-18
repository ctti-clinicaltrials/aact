namespace :import do
  namespace :restart1 do
    task :run, [:force] => :environment do |t, params|
      # Restart full load.  Load only studies with NCT IDs that end with 1
      ClinicalTrials::Updater.new({:event_type=>'full', :restart=>true,:study_filter=>'1'}).run
    end
  end
end
