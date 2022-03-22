namespace :acct do
  task :process, [] => :environment do
    updater = Util::Updater.new
    updater.start
  end
end
