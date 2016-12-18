namespace :import do
  namespace :restart6 do
    task :run, [:force] => :environment do |t, params|
      # Restart full load.  Load only studies with NCT IDs that end with 6
      ClinicalTrials::Updater.new({:event_type=>'full', :restart=>true,:study_filter=>'6'}).run
    end
  end
end
