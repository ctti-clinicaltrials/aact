namespace :daily_import do
  task run: :environment do
    DailyImportWorker.perform_async
  end
end
