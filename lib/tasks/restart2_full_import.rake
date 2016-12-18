namespace :import do
  namespace :restart2 do
    task :run, [:force] => :environment do |t, params|
      # Restart full load.  Load only studies with NCT IDs that end with 2
      ClinicalTrials::Updater.new({:event_type=>'full', :restart=>true,:study_filter=>'2'}).run
    end
  end
end
