namespace :table_export do
  task :run, [:force] => :environment do |t, args|
    if Date.today.day == 1 || args[:force]
      exporter = TableExporter.new
      exporter.run(delimiter: '|', should_upload_to_s3: true)
    else
      puts "Not the first of the month - not running table export"
    end
  end
end
