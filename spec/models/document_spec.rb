require 'rails_helper'

describe Document do
  it "study should have expected data in document fields" do
    nct_id='NCT03494712'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.documents.size).to eq(6)
    expect(study.documents.first.comment).to eq(nil)
    expect(study.documents.first.document_id).to eq(nil)
  end

  it "study should have document id, comment and long url fields" do
    nct_id='NCT03459976'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.documents.size).to eq(1)
    doc=study.documents.first
    expect(doc.document_id).to eq('10.1002/jcla.22223')
    expect(doc.document_type).to eq('Individual Participant Data Set')
    expect(doc.url).to eq('https://www.scopus.com/record/display.uri?eid=2-s2.0-85017447906&origin=resultslist&sort=plf-f&src=s&st1=DJ-1%3b+HE4%3b+PARK7%3b+endometrial+cancer&st2=&sid=c9b2b927dbc42cc33a01eb39e68b0a6d&sot=b&sdt=b&sl=51&s=TITLE-ABS-KEY%28DJ-1%3b+HE4%3b+PARK7%3b+endometrial+cancer%29&relpos=0&citeCnt=0&searchTerm=')
    expect(doc.comment).to eq('DJ-1; HE4; PARK7; endometrial cancer')
  end

end
