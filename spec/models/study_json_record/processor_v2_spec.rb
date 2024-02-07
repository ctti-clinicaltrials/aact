require 'rails_helper'

RSpec.describe StudyJsonRecord::ProcessorV2 do
  describe '#initialize' do
    it 'sets an instance variable @json with the JSON API data provided' do
      hash = JSON.parse(File.read('spec/support/json_data/study_data_initialize.json'))
      json_instance = described_class.new(hash)
      expect(json_instance.instance_variable_get('@json')).to eq(hash)
    end
  end

  describe '#design_groups_data' do
    it 'uses JSON API to generate data that will be inserted into the design groups table' do
      expected_data = {
        nct_id: 'NCT04207047',
        group_type: 'EXPERIMENTAL',
        title: 'Group A',
        description: 'Group A (up to n=5): Genius exposure 1-3 hours before tissue resection'
      },
      {
        nct_id: 'NCT04207047',
        group_type: 'EXPERIMENTAL',
        title: 'Group B',
        description: 'Group B (up to n=5): Genius exposure 30+7 days, 14+3 days, and 7+3 days before tissue resection. All test spot exposure visits will have a follow-up visit at 7+3 days after the test spot exposure visit.'
      },
      {
        nct_id: 'NCT04207047',
        group_type: 'EXPERIMENTAL',
        title: 'Group C',
        description: 'Group C (up to n=5): Genius exposure 90+14 days, 60+10 days, and 30+7 days before tissue resection. All test spot exposure visits will have a follow-up visit at 7+3 days after the test spot exposure visit.'
      },
      {
        nct_id: 'NCT04207047',
        group_type: 'EXPERIMENTAL',
        title: 'Group D',
        description: 'Group D (up to n=10): Genius, LaseMD, LaseMD FLEX, eCO2 and/or PicoPlus exposure 14+3 days, 7+3 days, and 1-3 hours before tissue resection. All test spot exposure visits will have a follow-up visit at 7+3 days after the test spot exposure visit.'
      }
      hash = JSON.parse(File.read('spec/support/json_data/NCT04207047.json'))
      processor = described_class.new(hash)
      expect(processor.design_groups_data).to eq(expected_data)
    end
  end

  describe '#brief_summary_data' do
    it 'tests brief_summary_data' do
      expected_data = {
        nct_id: 'NCT03630471',
        description: 'We will conduct a two-arm individually randomized controlled trial in six Government-run secondary schools in New Delhi. The targeted sample is 240 adolescents in grades 9-12 with persistent, elevated mental health difficulties and associated impact. Participants will receive either a brief problem-solving intervention delivered by lay counsellors (intervention), or enhanced usual care comprised of problem-solving booklets (control). Self-reported adolescent mental health difficulties and idiographic problems will be assessed at 6 weeks (co-primary outcomes) and again at 12 weeks post-randomization. In addition, adolescent-reported impact of mental health difficulties, perceived stress, mental wellbeing and clinical remission, as well as parent-reported adolescent mental health difficulties and impact scores, will be assessed at 6 and 12 weeks post-randomization. Parallel process evaluation, including estimations of the costs of delivering the interventions, will be conducted.'
      }
      hash = JSON.parse(File.read('spec/support/json_data/NCT03630471.json'))
      processor = described_class.new(hash)
      expect(processor.brief_summary_data).to eq(expected_data)
    end
  end

  describe '#links_data' do
    it 'uses JSON API to generate data that will be inserted into the links data table' do
      expected_data = [
        { nct_id: 'NCT02552212', url: 'http://www.fda.gov/Safety/MedWatch/SafetyInformation/default.htm', description: 'FDA Safety Alerts and Recalls' }
      ]
      hash = JSON.parse(File.read('spec/support/json_data/NCT02552212.json'))
      processor = described_class.new(hash)
      expect(processor.links_data).to eq(expected_data)
    end
  end

  describe '#documents_data' do
    it 'tests documents_data' do
      expected_data = {
        nct_id: 'NCT00465816',
        document_id: '109063',
        document_type: 'Dataset Specification',
        url: 'https://www.clinicalstudydatarequest.com',
        comment: 'For additional information about this study please refer to the GSK Clinical Study Register'
      }

      hash = JSON.parse(File.read('spec/support/json_data/NCT00465816.json'))
      processor = described_class.new(hash)
      expect(processor.documents_data.first).to eq(expected_data)
    end
  end

  describe '#eligibility_data' do
    it 'tests eligibility_data' do
      expected_data = {
        nct_id: 'NCT06171568',
        sampling_method: 'NON_PROBABILITY_SAMPLE',
        population: 'Patients hospitalized at Lariboisière hospital...',
        maximum_age: 'N/A',
        minimum_age: '18 Years',
        gender: 'ALL',
        gender_based: nil,
        gender_description: nil,
        healthy_volunteers: false,
        criteria: "Inclusion Criteria:\n\n* Patient over 18 years...",
        adult: true,
        child: false,
        older_adult: true
      }

      hash = JSON.parse(File.read('spec/support/json_data/NCT06171568.json'))
      processor = described_class.new(hash)
      expect(processor.eligibility_data).to eq(expected_data)
    end
  end

  participant_flow_data_expected = {
    nct_id: 'NCT02299791',
    recruitment_details: 'Recruitment was done at the clinic level. All patients seen in the clinics were potentially eligible for the intervention based on clinic visit and clinical criteria.',
    pre_assignment_details: 'There were two additional nested substudy randomizations after initial trial enrolment (see inclusion/exclusion criteria for eligibility). From 8/2009 to 6/2010, eligible children were randomized to once vs twice daily abacavir+lamivudine. From 9/2009 to 2/2011, eligible children were randomized to stop vs continue cotrimoxazole prophylaxis.',
    units_analyzed: 'Clinics'
  }

  describe '#participant_flow_data' do
    it 'uses JSON API to generate data that will be inserted into the participant_flows table' do
      hash = JSON.parse(File.read('spec/support/json_data/initialize_participant_flow_data.json'))
      json_instance = described_class.new(hash)
      expect(json_instance.participant_flow_data).to eq(participant_flow_data_expected)
    end
  end

  describe '#conditions_data' do
    let(:test_json) do
      {
        'protocolSection' => {
          'identificationModule' => { 'nctId' => '12345' },
          'conditionsModule' => { 'conditions' => %w[Condition1 Condition2] }
        }
      }
    end

    it 'returns a collection with correct conditions data' do
      expected_output = [
        { nct_id: '12345', name: 'Condition1', downcase_name: 'condition1' },
        { nct_id: '12345', name: 'Condition2', downcase_name: 'condition2' }
      ]
      processor = described_class.new(test_json)
      expect(processor.conditions_data).to eq(expected_output)
    end
  end

    participant_flow_data_expected =
    {
      :nct_id                 => "NCT02299791",
      :recruitment_details    => "Recruitment was done at the clinic level. All patients seen in the clinics were potentially eligible for the intervention based on clinic visit and clinical criteria.",
      :pre_assignment_details => "There were two additional nested substudy randomizations after initial trial enrolment (see inclusion/exclusion criteria for eligibility). From 8/2009 to 6/2010, eligible children were randomized to once vs twice daily abacavir+lamivudine. From 9/2009 to 2/2011, eligible children were randomized to stop vs continue cotrimoxazole prophylaxis.",
      :units_analyzed         => "Clinics"
    }

    describe '#participant_flow_data' do
      it 'should use JSON API to generate data that will be inserted into the participant_flows table' do
        hash = JSON.parse(File.read('spec/support/json_data/initialize_participant_flow_data.json'))
        json_instance = StudyJsonRecord::ProcessorV2.new(hash)
        expect(json_instance.participant_flow_data).to eq(participant_flow_data_expected)
      end 
    end   

  describe '#keywords_data' do
    it 'uses JSON API to generate data that will be inserted into the keywords data table' do
      expected_data = [
        { nct_id: 'NCT02552212', name: 'Axial Spondyloarthritis', downcase_name: 'Axial Spondyloarthritis'.downcase },
        { nct_id: 'NCT02552212', name: 'axSpA', downcase_name: 'axSpA'.downcase },
        { nct_id: 'NCT02552212', name: 'Ankylosing Spondylitis', downcase_name: 'Ankylosing Spondylitis'.downcase },
        { nct_id: 'NCT02552212', name: 'Anti TNF-alpha', downcase_name: 'Anti TNF-alpha'.downcase },
        { nct_id: 'NCT02552212', name: 'Certolizumab Pegol', downcase_name: 'Certolizumab Pegol'.downcase },
        { nct_id: 'NCT02552212', name: 'Nr-axSpA', downcase_name: 'Nr-axSpA'.downcase },
        { nct_id: 'NCT02552212', name: 'Non-radiographic', downcase_name: 'Non-radiographic'.downcase },
        { nct_id: 'NCT02552212', name: 'Spondylarthropathies', downcase_name: 'Spondylarthropathies'.downcase },
        { nct_id: 'NCT02552212', name: 'Arthritis', downcase_name: 'Arthritis'.downcase },
        { nct_id: 'NCT02552212', name: 'Spinal Diseases', downcase_name: 'Spinal Diseases'.downcase },
        { nct_id: 'NCT02552212', name: 'Immunosuppressive Agents', downcase_name: 'Immunosuppressive Agents'.downcase }
      ]
      hash = JSON.parse(File.read('spec/support/json_data/NCT02552212.json'))
      processor = described_class.new(hash)
      expect(processor.keywords_data).to eq(expected_data)
    end
  end

  describe '#detailed_description_data' do
    it 'tests detailed_description_data' do
      expected_data = {
        nct_id: 'NCT03630471',
        description: "Background and rationale:\n\nThis study is part of a larger research program called PRIDE (PRemIum for aDolEscents) for which the goals are to:\n\n*"
      }
      hash = JSON.parse(File.read('spec/support/json_data/detailed-description.json'))
      processor = described_class.new(hash)
      expect(processor.detailed_description_data).to eq(expected_data)
    end
  end

  describe '#central_contacts_data' do
    it 'tests central contacts parsing' do
      expected_data = [{
        nct_id: 'NCT04523987',
        contact_type: 'primary',
        name: 'Cheng Ean Chee',
        phone: '6779 5555',
        email: 'cheng_ean_chee@nuhs.edu.sg',
        phone_extension: nil,
        role: 'CONTACT'
      }]

      hash = JSON.parse(File.read('spec/support/json_data/central-data.json'))
      processor = described_class.new(hash)
      expect(processor.central_contacts_data).to eq(expected_data)
    end
  end

  describe '#ipd_information_types_data' do
    it 'uses JSON API to generate data that will be inserted into the ipd information types table' do
      expected_data = [
        { nct_id: 'NCT03630471', name: 'STUDY_PROTOCOL' },
        { nct_id: 'NCT03630471', name: 'SAP' },
        { nct_id: 'NCT03630471', name: 'ICF' }
      ]
      hash = JSON.parse(File.read('spec/support/json_data/NCT03630471.json'))
      processor = described_class.new(hash)
      expect(processor.ipd_information_types_data).to eq(expected_data)
    end
  end

  describe '#result_contact_data' do
    let(:results_section) { {} }
    let(:protocol_section) { {} }

    before do
      allow(processor).to receive(:results_section).and_return(results_section)
      allow(processor).to receive(:protocol_section).and_return(protocol_section)
    end

    context 'when point_of_contact is present' do
      let(:protocol_section) do
        { 'identificationModule' => { 'nctId' => '12345' } }
      end
      let(:results_section) do
        {
          'moreInfoModule' => {
            'pointOfContact' => {
              'phoneExt' => '123',
              'phone' => '555-1234',
              'title' => 'Manager',
              'organization' => 'Org',
              'email' => 'contact@example.com'
            }
          }
        }
      end
      let(:processor) { StudyJsonRecord::ProcessorV2.new(:results_section) }

      it 'returns contact data hash including email' do
        expect(processor.result_contact_data).to eq({
          nct_id: '12345',
          ext: '123',
          phone: '555-1234',
          name: 'Manager',
          organization: 'Org',
          email: 'contact@example.com'
        })
      end
    end

    context 'when results_section is not present' do
      let(:results_section) { nil }
      let(:processor) { StudyJsonRecord::ProcessorV2.new(:results_section) }

      it 'returns nil' do
        expect(processor.result_contact_data).to be_nil
      end
    end

    context 'when point_of_contact is not present in results_section' do
      let(:results_section) { { 'moreInfoModule' => {} } }
      let(:processor) { StudyJsonRecord::ProcessorV2.new(:results_section) }

      it 'returns nil' do
        expect(processor.result_contact_data).to be_nil
      end      
    end
  end
  
end
