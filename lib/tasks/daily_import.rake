namespace :import do
  namespace :daily do
    task :run, [:days_back] => :environment do |t, args|
      if ![1,4,8,12,16,22,26,30].include? Date.today.day || args[:force]
        ClinicalTrials::Updater.new.daily(args)
      end
    end
  end
end
