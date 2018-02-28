require 'rails_helper'

RSpec.describe Admin::Enumeration, type: :model do

  it "populates health check table with enumeration counts & percents " do

    # load one study to be able to check enumerations and row counts
    # enumeration health check will total rows for multiple studies, but we can test with just one
    table_name='reported_events'
    column_name='event_type'
    col_value1='other'
    col_value2='serious'
    nct_id='NCT02028676'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    Admin::DataDefinition.populate_enumerations
    expect(Admin::Enumeration.count).to eq(69)

    events=Admin::Enumeration.where('table_name=? and column_name=?',table_name, column_name)
    expect(events.count).to eq(2)
    # 36 (10.26%) of the sample study's reported events are of type 'other'
    e=events.each.select{|e|e.column_value==col_value1}
    expect(e.first.value_count).to eq(36)
    expect(e.first.value_percent.round(2)).to eq(10.26)

    # 315 (8.74%) of the sample study's reported events are of type 'serious'
    e=events.each.select{|e|e.column_value==col_value2}
    expect(e.first.value_count).to eq(315)
    pct=e.first.value_percent
    expect(pct.round(2).to_s).to eq('89.74')

    pct_decreased_compare=Admin::Enumeration.new({
      :table_name=>table_name,
      :column_name=>column_name,
      :column_value=>col_value1,
      :value_count=>100,
      :value_percent=>1.20})
    pct_decreased_compare.save!
    Admin::SanityCheck.new.check_enumerations
    results=Admin::SanityCheck.where('table_name=? and column_name=?',table_name,column_name)
    expect(results.size).to eq(1)
    chk=results.first
    expect(chk.check_type).to eq('enumeration')
    expect(chk.description).to eq('enumeration changed by more than 5%: 10.26% -> 1.2%')
    pct_decreased_compare.destroy
    chk.destroy
    expect(Admin::SanityCheck.count).to eq(0)
    pct_increased_compare=Admin::Enumeration.new({
      :table_name=>table_name,
      :column_name=>column_name,
      :column_value=>col_value1,
      :value_count=>500,
      :value_percent=>90.1})
    pct_increased_compare.save!
    Admin::SanityCheck.new.check_enumerations
    expect(Admin::SanityCheck.count).to eq(1)
    results=Admin::SanityCheck.where('table_name=? and column_name=?',table_name,column_name)
    expect(results.size).to eq(1)
    chk=results.first
    expect(chk.check_type).to eq('enumeration')
    expect(chk.description).to eq('enumeration changed by more than 5%: 10.26% -> 90.1%')
  end

end
