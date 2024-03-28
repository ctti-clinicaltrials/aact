require 'rails_helper'

describe DesignGroup do
  it "should create multiple instances of DesignGroup", schema: :v2 do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "title" => "Electroacupuncture plus pelvic floor muscle training",
        "group_type" => "EXPERIMENTAL",
        "description" => "experimental description"
      },
      {
        "nct_id" => "NCT000001",
        "title" => "Sham electroacupuncture plus pelvic floor muscle training",
        "group_type" => "SHAM_COMPARATOR",
        "description" => "sham description"
      }
    ]

    # load the json
    content = JSON.parse(File.read('spec/support/json_data/design_group.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = DesignGroup.all.map{|x| x.attributes }
    imported.each{|x| x.delete("id")}
    expect(imported).to eq(expected_data)
  end
end
