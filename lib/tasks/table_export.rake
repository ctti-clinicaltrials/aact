namespace :table_export do
  task run: :environment do
    TableExportWorker.perform_async('|')
  end
end
