require 'rails_helper'

describe Util::FileManager do
  context 'create static db copy' do
    it "should save db static copy to the appropriate directory" do
      allow_any_instance_of(Util::FileManager).to receive(:static_copies_directory).and_return('spec/support/shared_examples')
      allow_any_instance_of(Util::FileManager).to receive(:admin_schema_diagram).and_return("spec/support/shared_examples/aact_admin_schema.png")
      allow_any_instance_of(Util::FileManager).to receive(:schema_diagram).and_return("spec/support/shared_examples/aact_schema.png")
      allow_any_instance_of(Util::FileManager).to receive(:make_file_from_website).and_return("spec/support/shared_examples/nlm_results_definitions.html")

      fm=Util::FileManager.new
      File.delete(fm.pg_dump_file) if File.exist?(fm.pg_dump_file)
      expect(File.exist?(fm.pg_dump_file)).to eq(false)

      dm=Util::DbManager.new(:load_event=>Support::LoadEvent.create({:event_type=>'incremental',:status=>'running',:description=>'',:problems=>''}))
      dm.dump_database
      expect(File.size(fm.pg_dump_file) > 50000).to eq(true)

      zip_file=fm.save_static_copy
      expect(File).to exist(zip_file)
      # Manager returns the dmp file from zip file content
      dump_file=fm.get_dump_file_from(zip_file)
      expect(dump_file.name).to eq('postgres_data.dmp')

      # The dump file contains commands to create the database"
      content=dump_file.get_input_stream.read
      expect(content).to include("CREATE SCHEMA ctgov")
#      expect(content.scan('DROP TABLE').size).to eq(45)
#      expect(content.scan('CREATE TABLE').size).to eq(45)
      # If manager asked to get dmp file from the dmp file itself, it should simply return it
      dump_file2=fm.get_dump_file_from(dump_file)
      expect(dump_file.name).to eq('postgres_data.dmp')
    end

    it 'should not display files that are not downloadable zip files' do
      dir_name="#{Rails.public_path}/static/tmp/static_copies"
      FileUtils.remove_dir(dir_name) if File.exists?(dir_name)
      FileUtils.mkdir_p(dir_name)
      allow_any_instance_of(Util::FileManager).to receive(:static_copies_directory).and_return(dir_name)
      fm=Util::FileManager.new

      good_file_name="#{fm.static_copies_directory}/20180404_clinical_trials.zip"
      good_file=File.new(good_file_name,"w")
      expect(File).to exist(good_file)

      bad_file_name="#{fm.static_copies_directory}/.nfs00000001c324f8c500000001"
      bad_file=File.new(bad_file_name,"w")
      expect(File).to exist(bad_file)
      FileUtils.remove_dir(dir_name)
    end

  end

end
