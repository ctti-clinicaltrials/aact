namespace :grant do
  namespace :db_privs do
    task :run, [:force] => :environment do |t, params|
      Util::DbManager.new.grant_db_privs
    end
  end
end
