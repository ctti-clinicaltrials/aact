namespace :table_export do
  task :run, [:force] => :environment do |t, args|
    exporter = TableExporter.new
    exporter.run(delimiter: '|', should_upload_to_s3: true)
  end
end
