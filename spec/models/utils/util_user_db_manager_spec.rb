require 'rails_helper'

describe Util::UserDbManager do
  let(:username) { 'testuser' }
  let(:original_password) { 'original_password' }
  let(:dummy_password) { ENV['UNCONFIRMED_USER_PASSWORD'] }

  subject { described_class.new }

  context 'when managing user accounts' do
    it 'should create initial db account that user cannot access' do
      user=User.create({:last_name=>'lastname',:first_name=>'firstname',:email=>'email@mail.com',:username=>username,:password=>original_password,:skip_password_validation=>true})
      # make sure user account doesn't already exist
      Util::DbManager.new.grant_db_privs
      subject.remove_user(user.username)
      expect(subject.can_create_user_account?(user)).to be(true)
      expect(subject.create_user_account(user)).to be(true)

      expect(subject.user_account_exists?(user.username)).to be(true)
      expect(subject.can_create_user_account?(user)).to be(false)
      user_rec=described_class.new.pub_con.execute("SELECT * FROM pg_catalog.pg_group where groname = '#{user.username}'")
      expect(user_rec.count).to eq(1)
      user.remove
      expect(User.count).to eq(0)
      user_rec=described_class.new.pub_con.execute("SELECT * FROM pg_catalog.pg_group where groname = '#{user.username}'")
      expect(user_rec.count).to eq(0)
    end

  end
end
