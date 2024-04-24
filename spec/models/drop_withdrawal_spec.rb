require 'rails_helper'

describe DropWithdrawal do
  it "should create an instance of DropWithdrawal", schema: :v2 do
    # load the json
    content = JSON.parse(File.read('spec/support/json_data/drop_withdrawl.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    result_group = ResultGroup.first
    imported = DropWithdrawal.all.map{|x| x.attributes }
    imported.each{|x| x.delete("id")}

    expected = [
      {
        "result_group_id" => result_group.id,
        "nct_id" => "NCT000001",
        "ctgov_group_code" => "FG000",
        "period" => "Overall Study",
        "reason" => "Objective progression or relapse",
        "count" => 8,
        "drop_withdraw_comment" => "Participants discontinued due to disease progression.",
        "reason_comment" => "Participants discontinued due to disease progression.",
        "count_units" => 8
      },
      {
        "result_group_id" => result_group.id,
        "nct_id" => "NCT000001",
        "ctgov_group_code" => "FG000",
        "period" => "Overall Study",
        "reason" => "Withdrawal by Subject",
        "count" => 1,
        "drop_withdraw_comment" => nil,
        "reason_comment" => nil,
        "count_units" => nil
      },
      {
        "result_group_id" => result_group.id,
        "nct_id" => "NCT000001",
        "ctgov_group_code" => "FG000",
        "period" => "Overall Study",
        "reason" => "Adverse Event",
        "count" => 2,
        "drop_withdraw_comment" => "Two participants had adverse events.",
        "reason_comment" => "Two participants had adverse events.",
        "count_units" => 2
      },
      {
        "result_group_id" => result_group.id,
        "nct_id" => "NCT000001",
        "ctgov_group_code" => "FG000",
        "period" => "Overall Study",
        "reason" => "Sponsor Decision",
        "count" => 1,
        "drop_withdraw_comment" => nil,
        "reason_comment" => nil,
        "count_units" => 1
      },
      {
        "result_group_id" => result_group.id,
        "nct_id" => "NCT000001",
        "ctgov_group_code" => "FG000",
        "period" => "Overall Study",
        "reason" => "Met study discontinuation criteria",
        "count" => 4,
        "drop_withdraw_comment" => "Met predefined criteria for discontinuation.",
        "reason_comment" => "Met predefined criteria for discontinuation.",
        "count_units" => nil
      },
      {
        "result_group_id" => result_group.id,
        "nct_id" => "NCT000001",
        "ctgov_group_code" => "FG000",
        "period" => "Overall Study",
        "reason" => "Protocol Deviation",
        "count" => 3,
        "drop_withdraw_comment" => nil,
        "reason_comment" => "Three instances of protocol deviation.",
        "count_units" => 3
      }
    ]
    expect(imported).to eq(expected)
  end
end
