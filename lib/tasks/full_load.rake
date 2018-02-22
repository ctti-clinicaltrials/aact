namespace :full do
  namespace :load do
    task :run, [:force] => :environment do |t, args|
      Util::Updater.new({:event_type => 'full'}).run
    end
  end
end
