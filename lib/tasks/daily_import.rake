namespace :import do
  namespace :daily do
    task :run, [:days_back] => :environment do |t, args|
      Util::Updater.new(args).incremental
    end
  end
end
