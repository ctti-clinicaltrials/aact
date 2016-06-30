require 'rails_helper'

describe Study do
  subject { Study.new({xml: Nokogiri::XML(File.read(Rails.root.join('spec',
                                                          'support',
                                                          'xml_data',
                                                          'example_study.xml'))), nct_id: 'NCT00002475'}).create }

  describe 'associations' do
    it { should have_one(:brief_summary).dependent(:destroy) }
    it { should have_one(:design).dependent(:destroy) }
    it { should have_one(:detailed_description).dependent(:destroy) }
    it { should have_one(:eligibility).dependent(:destroy) }
    it { should have_one(:participant_flow).dependent(:destroy) }
    it { should have_one(:result_detail).dependent(:destroy) }
    it { should have_one(:derived_value).dependent(:destroy) }
    it { should have_one(:study_xml_record) }

    it { should have_many(:reviews).dependent(:destroy) }
    it { should have_many(:pma_mappings) }
    it { should have_many(:pma_records).dependent(:destroy) }
    it { should have_many(:expected_groups).dependent(:destroy) }
    it { should have_many(:expected_outcomes).dependent(:destroy) }
    it { should have_many(:groups).dependent(:destroy) }
    it { should have_many(:outcomes).dependent(:destroy) }
    it { should have_many(:baseline_measures).dependent(:destroy) }
    it { should have_many(:browse_conditions).dependent(:destroy) }
    it { should have_many(:browse_interventions).dependent(:destroy) }
    it { should have_many(:conditions).dependent(:destroy) }
    it { should have_many(:drop_withdrawals).dependent(:destroy) }
    it { should have_many(:facilities).dependent(:destroy) }
    it { should have_many(:interventions).dependent(:destroy) }
    it { should have_many(:keywords).dependent(:destroy) }
    it { should have_many(:links).dependent(:destroy) }
    it { should have_many(:milestones).dependent(:destroy) }
    it { should have_many(:location_countries).dependent(:destroy) }
    it { should have_many(:outcome_measures).dependent(:destroy) }
    it { should have_many(:overall_officials).dependent(:destroy) }
    it { should have_many(:oversight_authorities).dependent(:destroy) }
    it { should have_many(:reported_events).dependent(:destroy) }
    it { should have_many(:responsible_parties).dependent(:destroy) }
    it { should have_many(:result_agreements).dependent(:destroy) }
    it { should have_many(:result_contacts).dependent(:destroy) }
    it { should have_many(:secondary_ids).dependent(:destroy) }
    it { should have_many(:sponsors).dependent(:destroy) }
    it { should have_many(:references).dependent(:destroy) }
  end

  describe '.create_derived_values' do
    before do
      expect(subject).to be_persisted
    end

    it 'should create a derived value record for each study' do
      Study.create_derived_values

      expect(DerivedValue.count).to eq(1)
    end
  end

end