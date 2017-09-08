require 'rails_helper'

describe Util::FileManager do
  describe 'create snapshot' do
    it "should save db snapshots to the appropriate directory" do
      stub_request(:get, "https://prsinfo.clinicaltrials.gov/definitions.html").
           with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
           to_return(status: 200, body: "", headers: {})

      allow_any_instance_of(Util::FileManager).to receive(:make_file_from_website).and_return(Util::FileManager.schema_diagram)
      manager=Util::FileManager.new
      zip_file=manager.take_snapshot
      expect(File).to exist(zip_file)
      # Manager returns the dmp file from zip file content
      dump_file=manager.get_dump_file_from(zip_file)
      expect(dump_file.name).to eq('postgres_data.dmp')
      # If manager asked to get dmp file from the dmp file itself, it should simply return it
      dump_file2=manager.get_dump_file_from(dump_file)
      expect(dump_file.name).to eq('postgres_data.dmp')
    end
  end

end
