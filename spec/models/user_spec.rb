require 'rails_helper'

describe User do
  before(:all) do
    # In case tests failed in previous pass, remove db account in public database
    begin
      Util::UserManager.remove_user(User.new(:username=>'spec_test'))
    rescue
    end
  end

  it "isn't added if invalid name" do
    allow_any_instance_of(described_class).to receive(:can_access_db?).and_return( true )
    User.destroy_all
    expect(User.count).to eq(0)
    username='postgres'
    expect(User.create(:first_name=>'Illegal', :last_name=>'User',:email=>'illegal_user@duke.edu',:username=>username,:password=>'aact',:password_confirmation=>'aact').valid?).to eq(false)
    expect(User.count).to eq(0)
  end

  it "isn't accepted unless first char of username is alpha" do
    allow_any_instance_of(described_class).to receive(:can_access_db?).and_return( true )
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'1test@duke.edu',:username=>'1rspec_test',:password=>'aact')
    expect( user.valid? ).to eq(false)
    expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Username cannot contain special chars, Username must start with an alpha character")
    expect(User.count).to eq(0)
  end

  it "isn't accepted if username has a hyphen" do
    allow_any_instance_of(described_class).to receive(:can_access_db?).and_return( true )
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'1test@duke.edu',:username=>'r1-ectest',:password=>'aact')
    expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Username cannot contain special chars")
    expect(User.count).to eq(0)
  end

  it "accepted with a valid username and logs appropriate events when adding/removing user" do
    allow_any_instance_of(described_class).to receive(:can_access_db?).and_return( true )
    Admin::UserEvent.destroy_all
    User.destroy_all
    Util::UserDbManager.new.remove_user('r1ectest')
    user=User.create(:first_name=>'first', :last_name=>'last',:email=>'first.last@duke.edu',:username=>'r1ectest',:password=>'aact')
    user.skip_password_validation=true
    user.save!
    expect(User.count).to eq(1)
    expect(User.first.username).to eq('r1ectest')

    user.remove
    expect(User.count).to eq(0)
    expect(Admin::UserEvent.last.event_type).to eq('remove')
  end

  it "creates unconfirmed user db account in public db" do
    allow_any_instance_of(described_class).to receive(:can_access_db?).and_return( true )
    db_mgr=Util::UserDbManager.new({:load_event=>'unnecessary'})
    User.all.each{|user| user.remove }  # remove all existing users - both from Users table and db accounts
    username='rspec'
    pwd='aact_pwd'
    if Util::UserDbManager.new.user_account_exists? username
      db_mgr.pub_con.execute('drop owned by rspec;')
      db_mgr.pub_con.execute('drop user rspec;')
    end

    user=User.create(:first_name=>'first', :last_name=>'last',:email=>'rspec.test@duke.edu',:username=>username,:password=>pwd)
    user.skip_password_validation=true
    user.save!
    #db_mgr.create_user_account(user)
    expect(User.count).to eq(1)
    expect(user.sign_in_count).to eq(0)
    # user added to db as un-confirmed
    #expect(Util::UserDbManager.new.user_account_exists?(user.username)).to be(true)
    # user cannot login with the password they provided until they confirm their account
    begin
      con=PublicBase.establish_connection(
        adapter: 'postgresql',
        encoding: 'utf8',
        hostname: ENV['AACT_PUBLIC_HOSTNAME'],
        database: ENV['AACT_PUBLIC_DATABASE_NAME'],
        username: user.username,
        password: pwd,
      ).connection
    rescue => e
      e.inspect
      expect(e.message).to eq("FATAL:  role \"rspec\" is not permitted to log in\n")
      expect(con).to be(nil)
    end
    user.confirm  #simulate user email response confirming their account
    # once confirmed via email, user should be able to login to their account
    con=PublicBase.establish_connection(
      adapter: 'postgresql',
      encoding: 'utf8',
      hostname: ENV['AACT_PUBLIC_HOSTNAME'],
      database: ENV['AACT_PUBLIC_DATABASE_NAME'],
      username: user.username,
      password: pwd,
    ).connection
    expect(con.active?).to eq(true)
    con.execute('show search_path;')
    expect(con.execute('select count(*) from ctgov.studies').count).to eq(1)
    con.disconnect!
    expect(con.active?).to eq(false)
    con=nil

    user.remove
    expect(User.count).to eq(0)
    # user can no longer access the public database
    expect { PublicBase.establish_connection(
      adapter:'postgresql',
      encoding:'utf8',
      hostname: ENV['AACT_PUBLIC_HOSTNAME'],
      database: ENV['AACT_PUBLIC_DATABASE_NAME'],
      username: user.username,
    ).connection}.to raise_error(PG::ConnectionBad)
    # Subsequent spec tests use this public db connection. Force reset back to test db.
    @dbconfig = YAML.load(File.read('config/database.yml'))
    ActiveRecord::Base.establish_connection @dbconfig[:test]
  end

  it "isn't accepted if special char in username" do
    allow_any_instance_of(described_class).to receive(:can_access_db?).and_return( true )
    User.all.each{|user| user.remove}  # remove all existing users - both from Users table and db accounts
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'rspec.test@duke.edu',:username=>'rspec!_test',:password=>'aact')
    expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Username cannot contain special chars')
    expect(User.count).to eq(0)
    begin
      PublicBase.establish_connection(
        adapter: 'postgresql',
        encoding: 'utf8',
        hostname: ENV['AACT_PUBLIC_HOSTNAME'],
        database: ENV['AACT_PUBLIC_DATABASE_NAME'],
        username: user.username,
        password: user.password
      ).connection
    rescue => e
      expect(e.class).to eq(PG::ConnectionBad)
      expect(e.message).to eq("FATAL:  password authentication failed for user \"rspec!_test\"\n")
    end

    # Subsequent spec tests use this public db connection. Force reset back to test db.
    @dbconfig = YAML.load(File.read('config/database.yml'))
    ActiveRecord::Base.establish_connection @dbconfig[:test]
  end

  it { should validate_length_of(:first_name).is_at_most(100) }
  it { should validate_length_of(:last_name).is_at_most(100) }
  it { should validate_length_of(:username).is_at_most(64) }

end
