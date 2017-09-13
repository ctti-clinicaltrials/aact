require 'rails_helper'

describe User do

  it "adds user by creating row in Users table & creating a db account for the user" do
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'rspec.test@duke.edu',:db_username=>'rspec_test',:password=>'aact')
    user.save!
    expect(User.count).to eq(1)
    expect(user.sign_in_count).to eq(0)
    # user not added to db until confirmed
    begin
      con=ActiveRecord::Base.establish_connection(
        adapter: 'postgresql',
        encoding: 'utf8',
        database: 'aact',
        username: user.db_username
      ).connection
    rescue => e
      e.inspect
      expect(e.message).to eq("FATAL:  role \"rspec_test\" does not exist\n")
      expect(con).to be(nil)
    end
    user.confirm
    # user db account created when email confirmed
    con=ActiveRecord::Base.establish_connection(
      adapter: 'postgresql',
      encoding: 'utf8',
      database: 'aact',
      username: user.db_username
    ).connection
    expect(con.active?).to eq(true)
    con.disconnect!
    expect(con.active?).to eq(false)

    user.remove
    expect(User.count).to eq(0)
    # user can no longer access the public database
    begin
      ActiveRecord::Base.establish_connection(
        adapter: 'postgresql',
        encoding: 'utf8',
        database: 'aact',
        username: user.db_username
      ).connection
    rescue => e
      expect(e.class).to eq(ActiveRecord::NoDatabaseError)
    end
    # Subsequent spec tests use this public db connection. Force reset back to test db.
    @dbconfig = YAML.load(File.read('config/database.yml'))
    ActiveRecord::Base.establish_connection @dbconfig[:test]
  end
end
