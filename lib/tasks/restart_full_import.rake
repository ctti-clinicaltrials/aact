namespace :restart do
  namespace :load do
    task :run, [:force] => :environment do |t, params|
      # Restart full load - load all studies
      Util::Updater.new({:event_type=>'full', :restart=>true}).run
    end
  end
end
