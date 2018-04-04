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
      subject.remove_user(user)
      expect(subject.user_account_exists?(user)).to be(false)
      user.create_unconfirmed
      expect(user.unencrypted_password).to eq(original_password)

      expect(described_class.new.user_account_exists?(user)).to be(true)
      user_rec=described_class.new.pub_con.execute("SELECT * FROM pg_catalog.pg_user where usename = '#{user.username}'")
      expect(user_rec.count).to eq(1)
      expect(user.unencrypted_password).to eq(original_password)
      # once user is confirmed, the unencrypted_password should be set to nil (only used to set pwd for db acct)
      user.confirm
      expect(user.unencrypted_password).to eq(nil)
    end

  end
end
