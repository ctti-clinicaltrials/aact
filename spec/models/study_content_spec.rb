require 'rails_helper'

describe Study do
  context 'when patient data section exists' do
    it 'should have expected sharing ipd value' do
      xml=Nokogiri::XML(File.read('spec/support/xml_data/NCT02830269.xml'))
      study=Study.new({xml: xml, nct_id: 'NCT02830269'}).create
      expect(study.plan_to_share_ipd).to eq('Undecided')
    end

    it 'should have expected ipd description value' do
      xml=Nokogiri::XML(File.read('spec/support/xml_data/NCT02830269.xml'))
      study=Study.new({xml: xml, nct_id: 'NCT02830269'}).create
      expect(study.plan_to_share_description).to eq('NC')
    end
  end

  context 'when patient data section does not exist' do
    it 'should return empty string for sharing ipd value' do
      xml=Nokogiri::XML(File.read('spec/support/xml_data/example_study.xml'))
      study=Study.new({xml: xml, nct_id: 'NCT02260193'}).create
      expect(study.plan_to_share_ipd).to eq('')
    end

    it 'should return empty string for ipd description value' do
      xml=Nokogiri::XML(File.read('spec/support/xml_data/example_study.xml'))
      study=Study.new({xml: xml, nct_id: 'NCT02260193'}).create
      expect(study.plan_to_share_description).to eq('')
    end
  end
end
