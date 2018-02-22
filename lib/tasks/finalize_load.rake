namespace :finalize do
  namespace :load do
    task :run, [:force] => :environment do
      Util::Updater.new.finalize_load
    end
  end
end
