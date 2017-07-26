namespace :db do
  task :snapshot, [:force] => :environment do |t, params|
    Util::FileManager.new.take_snapshot
    Util::TableExporter.new.run
  end
end
