namespace :import do
  namespace :restart8 do
    task :run, [:force] => :environment do |t, params|
      # Restart full load.  Load only studies with NCT IDs that end with 8
      ClinicalTrials::Updater.new({:event_type=>'full', :restart=>true,:study_filter=>'8'}).run
    end
  end
end
