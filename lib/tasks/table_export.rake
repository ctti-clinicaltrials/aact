namespace :table_export do
  task :run, [:force] => :environment do |t, args|
    exporter = Util::TableExporter.new
    exporter.run(delimiter: '|', should_archive: true)
    beta_exporter = Util::TableExporter.new([], 'beta')
    beta_exporter.run(delimiter: '|', should_archive: true)
  end
end
