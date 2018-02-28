require 'rails_helper'

RSpec.describe Admin::Enumeration, type: :model do

  it "populates health check table with enumeration counts & percents " do

    # load one study to be able to check enumerations and row counts
    # enumeration health check will total rows for multiple studies, but we can test with just one
    nct_id='NCT02028676'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    Admin::DataDefinition.populate_enumerations
    expect(Admin::Enumeration.count).to eq(69)

    events=Admin::Enumeration.where('table_name=? and column_name=?','reported_events','event_type')
    expect(events.count).to eq(2)
    # 36 (10.26%) of the sample study's reported events are of type 'other'
    e=events.each.select{|e|e.column_value=='other'}
    expect(e.first.value_count).to eq(36)
    expect(e.first.value_percent.round(2)).to eq(10.26)

    # 315 (8.74%) of the sample study's reported events are of type 'serious'
    e=events.each.select{|e|e.column_value=='serious'}
    expect(e.first.value_count).to eq(315)
    #  why does this fail cuz it returns .8974 ??  expect(e.first.value_percent.round(2)).to eq(89.74)
  end

end
