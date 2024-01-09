require 'rails_helper'

describe ProvidedDocument do
  it "study should have expected provided_document info" do
    nct_id='NCT01298141'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.provided_documents.size).to eq(7)
    doc = study.provided_documents.select{|x| x.url == 'https://ClinicalTrials.gov/ProvidedDocs/41/NCT01298141/Prot_000.pdf'}.first
    expect(doc.document_type).to eq('Study Protocol: Original Protocol')
    expect(doc.document_date.strftime("%Y-%m-%d")).to eq('2010-09-30')
    expect(doc.has_protocol).to be(true)
    expect(doc.has_icf).to be(false)
    expect(doc.has_sap).to be(false)
  end

end

RSpec.describe ProvidedDocument do
  describe 'ProvidedDocument#mapper' do
    it 'study should have expected provided_document info' do
      expected_data = [
        { 
          nct_id: 'NCT03064438', 
          document_type: 'United States', 
          has_protocol: false
          has_icf: 'NCT02552212', 
          has_sap: 'Australia', 
          document_date: false,
          url: false
        },
        { 
          nct_id: 'NCT03064438', 
          document_type: 'United States', 
          has_protocol: false
          has_icf: 'NCT02552212', 
          has_sap: 'Australia', 
          document_date: false,
          url: false
        }
      ]
      hash = JSON.parse(File.read('spec/support/json_data/NCT02278341.json'))
      processor = StudyJsonRecord::ProcessorV2.new(hash)
      expect(Country.mapper(processor)).to eq(expected_data)
    end

    it 'when contact location country exist and removed country does not exist' do
      expected_data = [
        { 
          nct_id: 'NCT04207047', 
          name: 'United States', 
          removed: false
        }
      ]  
      hash = JSON.parse(File.read('spec/support/json_data/NCT04207047.json'))
      processor = StudyJsonRecord::ProcessorV2.new(hash)
      expect(Country.mapper(processor)).to eq(expected_data)
    end    
  end  
end
