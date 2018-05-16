require 'rails_helper'

describe PendingResult do
  it "study should have expected data in pending results fields" do
    nct_id='NCT03446690'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    expect(study.pending_results.size).to eq(3)
    submitted=study.pending_results.select{|x| x.event == 'submitted'}
    submitted1=submitted.select{|x| x.event_date_description == 'March 16, 2018'}
    returned=study.pending_results.select{|x| x.event=='returned'}
    expect(submitted.size).to eq(2)
    expect(submitted1.size).to eq(1)
    expect(returned.size).to eq(1)
    expect(returned.first.event_date).to eq('April 11, 2018'.to_date)
    expect(submitted1.first.event_date).to eq('March 16, 2018'.to_date)
  end

  it "study should handle strings in the date field" do
    nct_id='NCT03435185'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.pending_results.size).to eq(3)

    unknown=study.pending_results.select{|x| x.event_date_description == 'Unknown'}
    expect(unknown.size).to eq(1)
    expect(unknown.first.event_date).to eq(nil)
    expect(unknown.first.event).to eq('submission_canceled')
  end

end
