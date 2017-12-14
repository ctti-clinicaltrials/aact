require 'rails_helper'

describe User do
  before(:all) do
    # In case tests failed in previous pass, remove db account in public database
    begin
      Util::DbManager.remove_user(User.new(:username=>'spec_test'))
    rescue
    end
  end

  it "doesn't add users with db admin account names" do
    username='postgres'
    user=User.new(:first_name=>'Illegal', :last_name=>'User',:email=>'illegal_user@duke.edu',:username=>username,:password=>'aact',:password_confirmation=>'aact')
    expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Username Database account cannot be created for username '#{username}'")
    expect(User.count).to eq(0)
  end

  it "Doesn't accept user unless first char of username is alpha" do
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'1test@duke.edu',:username=>'1rspec_test',:password=>'aact')
    expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Username cannot contain special chars, Username must start with an alpha character')
    expect(User.count).to eq(0)
  end

  it "Doesn't accept username with hyphen" do
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'1test@duke.edu',:username=>'r1-ectest',:password=>'aact')
    expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Username cannot contain special chars')
    expect(User.count).to eq(0)
  end

  it "Accepts user with valid username" do
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'1test@duke.edu',:username=>'r1ectest',:password=>'aact')
    user.save!
    expect(User.count).to eq(1)
    expect(User.first.username).to eq('r1ectest')
    user.remove
    expect(User.count).to eq(0)
  end

  xit "creates unconfirmed accounts by inserting a row in Users table and creating an unconfirmed account in public db" do
    username='rspec'
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'rspec.test@duke.edu',:username=>username,:password=>'aact_pwd')
    unencrypted_password=user.password  # save this to use later
    user.unencrypted_password=unencrypted_password  #the original password saved by controller - so we can update db acct with it when user confirms
    user.create_unconfirmed
    expect(User.count).to eq(1)
    expect(user.sign_in_count).to eq(0)
    expect(user.unencrypted_password).to eq('aact_pwd')
    # user added to db as un-confirmed
    expect(Util::DbManager.new.user_account_exists?(user)).to be(true)
    # user cannot login with the password they provided until they confirm their account
    begin
      con=PublicBase.establish_connection(
        adapter: 'postgresql',
        encoding: 'utf8',
        hostname: ENV['AACT_PUBLIC_HOSTNAME'],
        database: ENV['AACT_PUBLIC_DATABASE_NAME'],
#        username: user.username,
#        password: user.unencrypted_password,
      ).connection
    rescue => e
      e.inspect
      expect(e.message).to eq("ActiveRecord::NoDatabaseError: FATAL:  role \"rspec\" does not exist\n")
      #expect(e.message).to eq("FATAL:  role \"rspec\" does not exist\n")
      expect(con).to be(nil)
    end
    user.confirm  #simulate user email response confirming their account
    # once confirmed via email, user should be able to login to their account
    con=PublicBase.establish_connection(
      adapter: 'postgresql',
      encoding: 'utf8',
      hostname: ENV['AACT_PUBLIC_HOSTNAME'],
      database: ENV['AACT_PUBLIC_DATABASE_NAME'],
#      username: user.username,
#      password: user.unencrypted_password,
    ).connection
    expect(con.active?).to eq(true)
    expect(con.execute('select count(*) from studies').count).to eq(1)
    con.disconnect!
    expect(con.active?).to eq(false)

    Util::DbManager.new.remove_user(user)
    expect(User.count).to eq(0)
    # user can no longer access the public database
    expect { PublicBase.establish_connection(
      adapter:'postgresql',
      encoding:'utf8',
      hostname: ENV['AACT_PUBLIC_HOSTNAME'],
      database: ENV['AACT_PUBLIC_DATABASE_NAME'],
#      username: user.username,
#      password: user.unencrypted_password
    ).connection}.to raise_error(ActiveRecord::NoDatabaseError)
    # Subsequent spec tests use this public db connection. Force reset back to test db.
    @dbconfig = YAML.load(File.read('config/database.yml'))
    ActiveRecord::Base.establish_connection @dbconfig[:test]
  end

  it "Doesn't accept users with special char in username" do
    User.destroy_all
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'rspec.test@duke.edu',:username=>'rspec!_test',:password=>'aact')
    expect { user.create_unconfirmed }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Username cannot contain special chars')
    expect(User.count).to eq(0)
    begin
      PublicBase.establish_connection(
        adapter: 'postgresql',
        encoding: 'utf8',
        hostname: ENV['AACT_PUBLIC_HOSTNAME'],
        database: ENV['AACT_PUBLIC_DATABASE_NAME'],
#        username: user.username
      ).connection
    rescue => e
      expect(e.class).to eq(ActiveRecord::NoDatabaseError)
      expect(e.message).to eq("FATAL:  role \"rspec!_test\" does not exist\n")
    end

    # Subsequent spec tests use this public db connection. Force reset back to test db.
    @dbconfig = YAML.load(File.read('config/database.yml'))
    ActiveRecord::Base.establish_connection @dbconfig[:test]
  end

  it { should validate_length_of(:first_name).is_at_most(100) }
  it { should validate_length_of(:last_name).is_at_most(100) }
  it { should validate_length_of(:username).is_at_most(64) }

end
