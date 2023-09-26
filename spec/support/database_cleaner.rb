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
    # PublicBase.establish_connection(
    #   adapter: 'postgresql',
    #   encoding: 'utf8',
    #   hostname: '127.0.0.1',
    #   port: 5432,
    #   database: 'aact_pub_test',
    #   username: 'aact',
    #   password: 'CCi3411'
    # )
    # con = PublicBase.connection
    DatabaseCleaner.start
  end

  config.after(:each) do
    @dbconfig = YAML.load(File.read('config/database.yml'))
    # backend db
    ActiveRecord::Base.establish_connection @dbconfig[:test]
    # and public db
    # PublicBase.establish_connection(
    #   adapter: 'postgresql',
    #   encoding: 'utf8',
    #   hostname: '127.0.0.1',
    #   port: 5432,
    #   database: 'aact_pub_test',
    #   username: 'aact',
    #   password: 'CCi3411'
    # )
    # con = PublicBase.connection
    DatabaseCleaner.clean
  end
end
