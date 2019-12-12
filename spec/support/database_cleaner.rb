RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:deletion)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :deletion
  end

  config.before(:each) do
    @dbconfig = YAML.load(File.read('config/database.yml'))
    # backend db
    ActiveRecord::Base.establish_connection @dbconfig[:test]
    # and public db
    con=PublicBase.establish_connection(
      adapter: 'postgresql',
      encoding: 'utf8',
      hostname: 'localhost',
      database: 'aact_pub_test',
      username: ENV["AACT_DB_SUPER_USERNAME"] || 'aact'
    ).connection
    DatabaseCleaner.start
  end

  config.after(:each) do
    @dbconfig = YAML.load(File.read('config/database.yml'))
    # backend db
    ActiveRecord::Base.establish_connection @dbconfig[:test]
    # and public db
    con=PublicBase.establish_connection(
      adapter: 'postgresql',
      encoding: 'utf8',
      hostname: 'localhost',
      database: 'aact_pub_test',
      username: ENV["AACT_DB_SUPER_USERNAME"] || 'aact'
    ).connection
    DatabaseCleaner.clean
  end
end
