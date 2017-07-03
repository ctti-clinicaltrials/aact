namespace :db do
  task :snapshot, [:force] => :environment do |t, params|
    ClinicalTrials::FileManager.new.take_snapshot
    ClinicalTrials::FileManager.new.create_flat_files
  end
end
