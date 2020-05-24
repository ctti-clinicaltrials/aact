require 'rails_helper'

describe IpdInformationType do

  # Will test all IPD-related attributes here, even tho most get saved to the Studies table
  # Just seems better to test all IPD stuff ere

  context 'when loading a study with all IPD data' do
    it 'should have expected sharing ipd values' do
      IpdInformationType.destroy_all
      nct_id='NCT03599518'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      study=Study.new({xml: xml, nct_id: nct_id}).create

      expect(study.plan_to_share_ipd).to eq('Yes')
      expect(study.plan_to_share_ipd_description).to eq("De-identified individual participant data (IPD) and applicable supporting clinical trial documents may be available upon request at https://www.clinicalstudydatarequest.com//. In cases where clinical trial data and supporting documents are provided pursuant to our company policies and procedures, Daiichi Sankyo will continue to protect the privacy of our clinical trial participants. Details on data sharing criteria and the procedure for requesting access can be found at this web address: https://www.clinicalstudydatarequest.com/Study-Sponsors/Study-Sponsors-DS.aspx")
      expect(study.ipd_time_frame).to eq('Studies for which the medicine and indication have received European Union (EU) and United States (US), and/or Japan (JP) marketing approval on or after 01 January 2014 or by the US or EU or JP Health Authorities when regulatory submissions in all regions are not planned and after the primary study results have been accepted for publication.')
      expect(study.ipd_access_criteria).to eq("Formal request from qualified scientific and medical researchers on IPD and clinical study documents from clinical trials supporting products submitted and licensed in the United States, the European Union and/or Japan from 01 January 2014 and beyond for the purpose of conducting legitimate research. This must be consistent with the principle of safeguarding study participants' privacy and consistent with provision of informed consent.")
      expect(study.ipd_url).to eq('https://www.clinicalstudydatarequest.com/Study-Sponsors/Study-Sponsors-DS.aspx')
      expect(study.ipd_information_types.size).to eq(5)
      expect(study.ipd_information_types.select{|i| i.name == 'Analytic Code' }.size).to eq(1)
      expect(study.ipd_information_types.select{|i| i.name == 'Clinical Study Report (CSR)' }.size).to eq(1)
      expect(study.ipd_information_types.select{|i| i.name == 'Informed Consent Form (ICF)' }.size).to eq(1)
      expect(study.ipd_information_types.select{|i| i.name == 'Statistical Analysis Plan (SAP)' }.size).to eq(1)
      expect(study.ipd_information_types.select{|i| i.name == 'Study Protocol' }.size).to eq(1)
    end

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
