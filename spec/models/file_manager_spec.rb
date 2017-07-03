require 'rails_helper'

describe ClinicalTrials::FileManager do
  it "should save db snapshots to the appropriate directory" do
    allow_any_instance_of(ClinicalTrials::FileManager).to receive(:make_file_from_website).and_return(ClinicalTrials::FileManager.schema_diagram)
    manager=ClinicalTrials::FileManager.new
    zip_file=manager.take_snapshot
    expect(File).to exist(zip_file)
  end

end
