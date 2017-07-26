namespace :db do |ns|
  task :activity, [:force] => :environment do |t, params|
    DatabaseActivity.populate(params)
  end
end
