require 'rails_helper'

describe Util::FileManager do
  it "should save db snapshots to the appropriate directory" do
    allow_any_instance_of(Util::FileManager).to receive(:make_file_from_website).and_return(Util::FileManager.schema_diagram)
    manager=Util::FileManager.new
    zip_file=manager.take_snapshot
    expect(File).to exist(zip_file)
  end

end
