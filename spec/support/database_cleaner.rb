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
    ActiveRecord::Base.establish_connection @dbconfig[:test]
    con=PublicBase.establish_connection(
      adapter: 'postgresql',
      encoding: 'utf8',
      hostname: ENV['AACT_PUBLIC_HOSTNAME'],
      database: ENV['AACT_PUBLIC_DATABASE_NAME'],
      username: ENV['AACT_DB_SUPER_USERNAME'],
    ).connection
    DatabaseCleaner.start
  end

  config.after(:each) do
    @dbconfig = YAML.load(File.read('config/database.yml'))
    ActiveRecord::Base.establish_connection @dbconfig[:test]
    con=PublicBase.establish_connection(
      adapter: 'postgresql',
      encoding: 'utf8',
      hostname: ENV['AACT_PUBLIC_HOSTNAME'],
      database: ENV['AACT_PUBLIC_DATABASE_NAME'],
      username: ENV['AACT_DB_SUPER_USERNAME'],
    ).connection
    DatabaseCleaner.clean
  end
end
