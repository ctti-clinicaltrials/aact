namespace :import do
  namespace :full do
    namespace :finalize do
      task :run, [:force] => :environment do |t, args|
        Util::Updater.new({:event_type=>'finalize'}).run
      end
    end
  end
end
