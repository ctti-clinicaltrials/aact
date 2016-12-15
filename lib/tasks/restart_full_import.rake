namespace :import do
  namespace :restart do
    task :run, [:force] => :environment do |t, params|
      ClinicalTrials::Updater.new({:event_type=>'full', :restart=>true}).run
    end
  end
end
