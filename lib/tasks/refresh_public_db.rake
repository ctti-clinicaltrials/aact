namespace :refresh do
  task :public_db, [:force] => :environment do |t|
    Util::DbManager.new.refresh_public_db
  end
end
