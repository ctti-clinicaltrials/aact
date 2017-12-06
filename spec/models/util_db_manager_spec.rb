require 'rails_helper'

describe Util::DbManager do
  let(:username) { 'test_user' }
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
      user_rec=described_class.new.con.execute("SELECT * FROM pg_catalog.pg_user where usename = '#{user.username}'")
      expect(user_rec.count).to eq(1)
      expect(user.unencrypted_password).to eq(original_password)
      # once user is confirmed, the unencrypted_password should be set to nil (only used to set pwd for db acct)
      user.confirm
      expect(user.unencrypted_password).to eq(nil)
    end
  end

  context 'when managing the databases' do
    it 'should restore the public db from current dump file - then both dbs should be identical' do
     stub_request(:get, "https://prsinfo.clinicaltrials.gov/results_definitions.html").
         with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
         to_return(status: 200, body: "", headers: {})

     stub_request(:get, "https://prsinfo.clinicaltrials.gov/definitions.html").
           with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
           to_return(status: 200, body: "", headers: {})

      dm=Util::DbManager.new
      dm.refresh_public_db
      back_db=ActiveRecord::Base.connection
      back_table_count=back_db.execute('select count(*) from information_schema.tables;').first['count'].to_i
      pub_table_count=dm.con.execute('select count(*) from information_schema.tables;').first['count'].to_i
      expect(back_table_count).to eq(pub_table_count)

      pub_study_count=dm.con.execute('select count(*) from studies').first['count'].to_i
      pub_outcome_count=dm.con.execute('select count(*) from outcomes').first['count'].to_i
      expect(Study.count).to eq(pub_study_count)
      expect(Outcome.count).to eq(pub_outcome_count)
    end
  end
end
