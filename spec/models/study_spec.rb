require 'rails_helper'

describe Study do
  subject { Study.new({xml: Nokogiri::XML(File.read(Rails.root.join('spec',
                                                          'support',
                                                          'xml_data',
                                                          'example_study.xml'))), nct_id: 'NCT00002475'}).create }

  describe 'associations' do
    it { should have_one(:brief_summary).dependent(:delete) }
    it { should have_one(:design).dependent(:delete) }
    it { should have_one(:detailed_description).dependent(:delete) }
    it { should have_one(:eligibility).dependent(:delete) }
    it { should have_one(:participant_flow).dependent(:delete) }
    it { should have_one(:calculated_value).dependent(:delete) }
    it { should have_one(:study_xml_record) }

    it { should have_many(:design_groups).dependent(:delete_all) }
    it { should have_many(:design_outcomes).dependent(:delete_all) }
    it { should have_many(:result_groups).dependent(:delete_all) }
    it { should have_many(:browse_conditions).dependent(:delete_all) }
    it { should have_many(:browse_interventions).dependent(:delete_all) }
    it { should have_many(:central_contacts).dependent(:delete_all) }
    it { should have_many(:conditions).dependent(:delete_all) }
    it { should have_many(:countries).dependent(:delete_all) }
    it { should have_many(:facilities).dependent(:delete_all) }
    it { should have_many(:interventions).dependent(:delete_all) }
    it { should have_many(:keywords).dependent(:delete_all) }
    it { should have_many(:links).dependent(:delete_all) }
    it { should have_many(:overall_officials).dependent(:delete_all) }
    it { should have_many(:oversight_authorities).dependent(:delete_all) }
    it { should have_many(:responsible_parties).dependent(:delete_all) }
    it { should have_many(:result_agreements).dependent(:delete_all) }
    it { should have_many(:result_contacts).dependent(:delete_all) }
    it { should have_many(:sponsors).dependent(:delete_all) }
    it { should have_many(:references).dependent(:delete_all) }
  end

  describe '.create_calculated_values' do
    before do
      expect(subject).to be_persisted
    end

    it 'should have created a calculated value record for each study' do
      expect(CalculatedValue.count).to eq(1)
    end
  end

  describe 'with_related_records' do
    it { is_expected.to respond_to 'with_related_records'}
    it { is_expected.to respond_to 'with_related_records=' }

    it 'should allow the with_related_records attribute to be set' do
      expect(subject.with_related_records).not_to be true
      subject.with_related_records = true
      expect(subject.with_related_records).to be true
    end
  end
end
