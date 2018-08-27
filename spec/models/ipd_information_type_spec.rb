require 'rails_helper'

describe IpdInformationType do

  # Will test all IPD-related attributes here, even tho most get saved to the Studies table
  # Just seems better to test all IPD stuff ere

  context 'when loading a study with IPD data in patient data section' do
 end

  context 'when patient data section does not exist' do
    nct_id='NCT02260193'
    xml=Nokogiri::XML(File.read('spec/support/xml_data/example_study.xml'))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    it 'should return empty string for sharing ipd value' do
      expect(study.plan_to_share_ipd).to eq(nil)
    end

    it 'should return empty string for ipd description value' do
      expect(study.plan_to_share_ipd_description).to eq(nil)
    end
  end

end
