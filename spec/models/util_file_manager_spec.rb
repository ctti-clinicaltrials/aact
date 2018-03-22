require 'rails_helper'

describe Util::FileManager do
  context 'removes files that accumulated through the past month' do
    it 'should remove flat pipe-delimited files created in previous month but not the one created on the first day of the month' do
      cur_month=Date.today.strftime("%m")
      cur_year=Date.today.year.to_s
      prev_date=Time.now - 1.month
      prev_month=prev_date.strftime("%m")
      prev_year=prev_date.year.to_s

      FileUtils.rm_rf(Dir['/aact-files/exported_files/*'])
      # create dummy test flat files.
      f1_should_keep="#{Util::FileManager.flat_files_directory}/20160901_clinical_trials.zip"
      f2_should_keep="#{Util::FileManager.flat_files_directory}/20141003_clinical_trials.zip"
      f3_should_keep="#{Util::FileManager.flat_files_directory}/#{cur_year}#{cur_month}01_clinical_trials.zip"
      f4_should_keep="#{Util::FileManager.flat_files_directory}/#{prev_year}#{prev_month}01_clinical_trials.zip"

      f5_should_remove="#{Util::FileManager.flat_files_directory}/#{prev_year}#{prev_month}03_clinical_trials.zip"
      f6_should_remove="#{Util::FileManager.flat_files_directory}/#{prev_year}#{prev_month}05_clinical_trials.zip"
      f7_should_remove="#{Util::FileManager.flat_files_directory}/#{prev_year}#{prev_month}25_clinical_trials.zip"

      # these should be kept
      f=File.new(f1_should_keep,'w')
      f=File.new(f2_should_keep,'w')
      f=File.new(f3_should_keep,'w')
      f=File.new(f4_should_keep,'w')

      # these should get removed
      f=File.new(f5_should_remove,'w')
      f=File.new(f6_should_remove,'w')
      f=File.new(f7_should_remove,'w')

      Util::FileManager.new.remove_daily_flat_files  #  <<<<<<  does all the work here

      expect(File).to exist(File.new(f1_should_keep))
      expect(File).to exist(File.new(f2_should_keep))
      expect(File).to exist(File.new(f3_should_keep))
      expect(File).to exist(File.new(f4_should_keep))

      expect { File.new(f5_should_remove) }.to raise_error(StandardError, /No such file or directory @ rb_sysopen/)
      expect { File.new(f6_should_remove) }.to raise_error(StandardError, /No such file or directory @ rb_sysopen/)
      expect { File.new(f7_should_remove) }.to raise_error(StandardError, /No such file or directory @ rb_sysopen/)

      FileUtils.rm_rf(Dir['/aact-files/exported_files/*'])
    end

    it 'should remove static db copies created in previous month but not the one created on the first day of the month' do
      cur_month=Date.today.strftime("%m")
      cur_year=Date.today.year.to_s
      prev_date=Time.now - 1.month
      prev_month=prev_date.strftime("%m")
      prev_year=prev_date.year.to_s

      FileUtils.rm_rf(Dir['/aact-files/static_db_copies/*'])
      # create dummy test static db copy files.
      f1_should_keep="#{Util::FileManager.static_copies_directory}/20160901_clinical_trials.zip"
      f2_should_keep="#{Util::FileManager.static_copies_directory}/20141003_clinical_trials.zip"
      f3_should_keep="#{Util::FileManager.static_copies_directory}/#{cur_year}#{cur_month}01_clinical_trials.zip"
      f4_should_keep="#{Util::FileManager.static_copies_directory}/#{prev_year}#{prev_month}01_clinical_trials.zip"

      f5_should_remove="#{Util::FileManager.static_copies_directory}/#{prev_year}#{prev_month}04_clinical_trials.zip"
      f6_should_remove="#{Util::FileManager.static_copies_directory}/#{prev_year}#{prev_month}15_clinical_trials.zip"
      f7_should_remove="#{Util::FileManager.static_copies_directory}/#{prev_year}#{prev_month}26_clinical_trials.zip"

      # these should be kept
      f=File.new(f1_should_keep,'w')
      f=File.new(f2_should_keep,'w')
      f=File.new(f3_should_keep,'w')
      f=File.new(f4_should_keep,'w')

      # these should get removed
      f=File.new(f5_should_remove,'w')
      f=File.new(f6_should_remove,'w')
      f=File.new(f7_should_remove,'w')

      Util::FileManager.new.remove_daily_snapshots  #  <<<<<<  does all the work here

      expect(File).to exist(File.new(f1_should_keep))
      expect(File).to exist(File.new(f2_should_keep))
      expect(File).to exist(File.new(f3_should_keep))
      expect(File).to exist(File.new(f4_should_keep))

      expect { File.new(f5_should_remove) }.to raise_error(StandardError, /No such file or directory @ rb_sysopen/)
      expect { File.new(f6_should_remove) }.to raise_error(StandardError, /No such file or directory @ rb_sysopen/)
      expect { File.new(f7_should_remove) }.to raise_error(StandardError, /No such file or directory @ rb_sysopen/)

      FileUtils.rm_rf(Dir['/aact-files/static_db_copies/*'])
    end
  end

  context 'create static db copy' do
    it "should save db static copy to the appropriate directory" do
      allow_any_instance_of(Util::FileManager).to receive(:make_file_from_website).and_return(Util::FileManager.new.backend_schema_diagram)
      fm=Util::FileManager.new
      dm=Util::DbManager.new(:load_event=>Admin::LoadEvent.create({:event_type=>'incremental',:status=>'running',:description=>'',:problems=>''}))
      dm.dump_database
      zip_file=dm.save_static_copy
      expect(File).to exist(zip_file)
      # Manager returns the dmp file from zip file content
      dump_file=fm.get_dump_file_from(zip_file)
      expect(dump_file.name).to eq('postgres_data.dmp')
      # The dump file contains commands to create the database"
      content=dump_file.get_input_stream.read
      expect(content).to include("CREATE DATABASE aact")
      expect(content.scan('DROP TABLE').size).to eq(42)
      expect(content.scan('CREATE TABLE').size).to eq(42)
      # If manager asked to get dmp file from the dmp file itself, it should simply return it
      dump_file2=fm.get_dump_file_from(dump_file)
      expect(dump_file.name).to eq('postgres_data.dmp')
    end
  end

end
