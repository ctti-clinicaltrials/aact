namespace :table_export do
  task run: :environment do
    exporter = TableExporter.new
    exporter.run(delimiter: '|', should_upload_to_s3: true)
  end
end
