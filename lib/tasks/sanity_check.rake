namespace :sanity_check do
  task run: :environment do |t|
    Util::Updater.new.run_sanity_checks
  end
end
