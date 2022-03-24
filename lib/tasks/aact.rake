namespace :aact do
  task :process, [] => :environment do
    updater = Util::Updater.new
    updater.start
  end
end
