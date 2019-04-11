require 'rails_helper'

describe Util::DbManager do

  subject { described_class.new }

  context 'when loading the databases' do
    it 'should add indexes and constraints' do
      event = Support::LoadEvent.create({:event_type=> 'test', :status => 'in prog'})
      mgr = Util::DbManager.new(event)
      mgr.add_indexes
      mgr.add_constraints
      study_indexes=mgr.indexes_for('studies')
      expect(study_indexes.values.size).to eq(15)

      mgr.remove_indexes_and_constraints
      study_indexes=mgr.indexes_for('studies')
      expect(study_indexes.values.size).to eq(0)

      mgr.add_indexes
      mgr.add_constraints
      study_indexes=mgr.indexes_for('studies')
      expect(study_indexes.values.size).to eq(15)

      design_indexes=mgr.indexes_for('designs')
      design_id_index=design_indexes.select{|di| di['column_name']=='id'}.first
      expect(design_id_index['is_primary']).to eq('t')
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

      Study.destroy_all
      pub_con = PublicBase.connection
      pub_con.execute('truncate table studies cascade')
      pub_con.execute('truncate table outcomes cascade')


      dm=Util::DbManager.new(:load_event=>Support::LoadEvent.create({:event_type=>'incremental',:status=>'running',:description=>'',:problems=>''}))
      fm=Util::FileManager.new
      dm.dump_database
      fm.save_static_copy
      dm.refresh_public_db

      back_con = ActiveRecord::Base.establish_connection(ENV["AACT_BACK_DATABASE_URL"]).connection
      back_tables=back_con.execute("select * from information_schema.tables where table_schema='ctgov'")
      back_table_count=back_con.execute("select count(*) from information_schema.tables where table_schema='ctgov'").first['count'].to_i

      #reset pub connection
      PublicBase.establish_connection(
        adapter: 'postgresql',
        encoding: 'utf8',
        hostname: ENV['AACT_PUBLIC_HOSTNAME'],
        database: ENV['AACT_PUBLIC_DATABASE_NAME'],
        username: ENV['AACT_DB_SUPER_USERNAME'])
      pub_con = PublicBase.connection

      pub_study_count=pub_con.execute('select count(*) from studies').first['count'].to_i
      pub_outcome_count=pub_con.execute('select count(*) from outcomes').first['count'].to_i


      pub_table_count=pub_con.execute("select count(*) from information_schema.tables where table_schema='ctgov'").first['count'].to_i
      pub_tables=pub_con.execute("select * from information_schema.tables where table_schema='ctgov'")
      # both dbs should have all the same tables except schema_migrations table is removed from public db
      #expect(back_table_count - 1).to eq(pub_table_count)

      pub_browse_condition_count=pub_con.execute('select count(*) from browse_conditions').first['count'].to_i
      pub_country_count=pub_con.execute('select count(*) from countries').first['count'].to_i
      pub_design_count=pub_con.execute('select count(*) from designs').first['count'].to_i
      pub_study_count=pub_con.execute('select count(*) from studies').first['count'].to_i
      pub_sponsor_count=pub_con.execute('select count(*) from sponsors').first['count'].to_i
      pub_outcome_count=pub_con.execute('select count(*) from outcomes').first['count'].to_i
      expect(BrowseCondition.count).to eq(pub_browse_condition_count)
      expect(Country.count).to eq(pub_country_count)
      expect(Design.count).to eq(pub_design_count)
      expect(Study.count).to eq(pub_study_count)
      expect(Sponsor.count).to eq(pub_sponsor_count)
      expect(Outcome.count).to eq(pub_outcome_count)
    end
  end
end
