require 'rails_helper'

describe User do

  it "adds user by creating row in Users table & creating a db account for the user" do
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'rspec.test@duke.edu',:username=>'rspec_test',:password=>'aact')
    user.save!
    expect(User.count).to eq(1)
    expect(user.sign_in_count).to eq(0)
    # user not added to db until confirmed
    begin
      con=ActiveRecord::Base.establish_connection(
        adapter: 'postgresql',
        encoding: 'utf8',
        database: 'aact',
        username: user.username
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
      username: user.username
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
        username: user.username
      ).connection
    rescue => e
      expect(e.class).to eq(ActiveRecord::NoDatabaseError)
    end
    # Subsequent spec tests use this public db connection. Force reset back to test db.
    @dbconfig = YAML.load(File.read('config/database.yml'))
    ActiveRecord::Base.establish_connection @dbconfig[:test]
  end

  it "Doesn't accept users with invalid char in username" do
    User.destroy_all
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'rspec.test@duke.edu',:username=>'rspec!_test',:password=>'aact')
    expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Username cannot contain special chars')
    expect(User.count).to eq(0)
    begin
      ActiveRecord::Base.establish_connection(
        adapter: 'postgresql',
        encoding: 'utf8',
        database: 'aact',
        username: user.username
      ).connection
    rescue => e
      expect(e.class).to eq(ActiveRecord::NoDatabaseError)
      expect(e.message).to eq("FATAL:  role \"rspec!_test\" does not exist\n")
    end

    # Subsequent spec tests use this public db connection. Force reset back to test db.
    @dbconfig = YAML.load(File.read('config/database.yml'))
    ActiveRecord::Base.establish_connection @dbconfig[:test]
  end

  it "Doesn't accept user unless first char of username is alpha" do
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'1test@duke.edu',:username=>'1rspec_test',:password=>'aact')
    expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Username must start with an alpha character')
    expect(User.count).to eq(0)
  end

  it "Accepts usernames with numbers" do
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'1test@duke.edu',:username=>'r1-ec_test',:password=>'aact').save!
    expect(User.count).to eq(1)
    expect(User.first.username).to eq('r1-ec_test')
  end

  it { should validate_length_of(:first_name).is_at_most(100) }
  it { should validate_length_of(:last_name).is_at_most(100) }
  it { should validate_length_of(:username).is_at_most(64) }

end
