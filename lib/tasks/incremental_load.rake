namespace :incremental do
  namespace :load do
    task :run, [:days_back] => :environment do |t, args|
      args[:event_type] = 'incremental'
      Util::Updater.new(args).run
    end
  end
end
