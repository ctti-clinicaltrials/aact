require 'rails_helper'
describe ReportedEvent do
  it "should not fail when expected data elements (such as sub_title) don't exist" do
    nct_id='NCT02317510'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    serious=study.reported_events.select{|x|x.event_type=='serious'}
  end
end
