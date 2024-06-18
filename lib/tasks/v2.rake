namespace :v2 do
  desc "Download Study"
  task :download, [:nct_id] => :environment do |t, args|
    StudyDownloader.download([args[:nct_id]])
  end

  desc "Load from File"
  task :load_from_file, [:file] => :environment do |t, args|
    StudyDownloader.load_from_file(args[:file])
  end
end