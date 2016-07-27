namespace :import do
  namespace :daily do
    task :run, [:days_back] => :environment do |t, args|
      DailyImportWorker.perform_async(args[:days_back].to_i)
    end
  end
end
