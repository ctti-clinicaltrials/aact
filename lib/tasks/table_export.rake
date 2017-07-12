namespace :table_export do
  task :run, [:force] => :environment do |t, args|
    exporter = ClinicalTrials::TableExporter.new
    exporter.run(delimiter: '|', should_upload_to_s3: true)
  end
end
