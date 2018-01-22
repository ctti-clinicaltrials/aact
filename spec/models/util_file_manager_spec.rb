require 'rails_helper'

describe Util::FileManager do
  describe 'create static db copy' do
    it "should save db static copy to the appropriate directory" do
      allow_any_instance_of(Util::FileManager).to receive(:make_file_from_website).and_return(Util::FileManager.new.backend_schema_diagram)
      fm=Util::FileManager.new
      dm=Util::DbManager.new
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
