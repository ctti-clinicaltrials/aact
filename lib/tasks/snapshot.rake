namespace :db do
  task :snapshot, [:force] => :environment do |t, params|
    Util::Updater.new.take_snapshot
    Util::Updater.new.take_snapshot('beta')
  end
end
