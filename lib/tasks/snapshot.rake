namespace :db do
  task :snapshot, [:force] => :environment do |t, params|
    ClinicalTrials::FileManager.new.take_snapshot
    ClinicalTrials::TableExporter.new.run
  end
end
