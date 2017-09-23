require 'rails_helper'

describe Util::DbManager do
  let(:username) { 'test_user' }
  let(:original_password) { 'original_password' }
  let(:new_password) { 'new_password' }
  let(:dummy_password) { ENV['UNCONFIRMED_USER_PASSWORD'] }

  subject { described_class.new }

  context 'create unconfirmed db account' do
    it 'should create db account that user cannot access' do
      user=User.create({:last_name=>'lastname',:first_name=>'firstname',:email=>'email@mail.com',:username=>username,:password=>original_password,:skip_password_validation=>true})
      # make sure user account doesn't already exist
      subject.remove_user(user)
      expect(subject.user_account_exists?(user)).to be(false)
      user.create_unconfirmed
      expect(user.unencrypted_password).to eq(original_password)

      expect(described_class.new.user_account_exists?(user)).to be(true)
      user_rec=described_class.new.con.execute("SELECT * FROM pg_catalog.pg_user where usename = '#{user.username}'")
      expect(user_rec.count).to eq(1)
      # Test public db is generally ok & accessible
      con=ActiveRecord::Base.establish_connection(
        :adapter  => "postgresql",
        :host     => "localhost",
        :database => "aact",
        :username => user.username,
        :password => dummy_password,
      ).connection
      expect(con.active?).to be(true)
      con.disconnect!
      expect(con.active?).to be(false)

      # user can't login with their password until they confirm their email
      con=ActiveRecord::Base.establish_connection(
        :adapter  => "postgresql",
        :host     => "localhost",
        :database => "aact",
        :username => user.username,
        :password => 'sdfsdfsdfs'
      ).connection
      expect(con.active?).to be(false)
     #  Confirm the user and they should now be able to login to the db
#      user.confirm
#      con=ActiveRecord::Base.establish_connection(
#        :adapter  => "postgresql",
#        :host     => "localhost",
#        :database => "aact",
#        :username => "#{user.username}",
#        :password => "#{user.password}",
#      ).connection
#      expect(con.active?).to be(true)
#      con.disconnect!
    end
  end
end
