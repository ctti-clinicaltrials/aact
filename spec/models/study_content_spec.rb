require 'rails_helper'

describe Study do
  context 'when patient data section exists' do
    it 'should have expected sharing ipd value' do
      xml=Nokogiri::XML(File.read('spec/support/xml_data/NCT02830269.xml'))
      study=Study.new({xml: xml, nct_id: 'NCT02830269'}).create
      expect(study.plan_to_share_ipd).to eq('Undecided')
    end
  end

  context 'when patient data section does not exist' do
    it 'should return nil' do
      xml=Nokogiri::XML(File.read('spec/support/xml_data/example_study.xml'))
      study=Study.new({xml: xml, nct_id: 'NCT02260193'}).create
      #binding.pry
      expect(study.plan_to_share_ipd).to eq('')
    end
  end
end
