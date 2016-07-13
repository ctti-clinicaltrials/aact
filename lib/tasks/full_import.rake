namespace :import do
  namespace :full do
    task run: :environment do
      FullImportWorker.perform_async
    end
  end
end
