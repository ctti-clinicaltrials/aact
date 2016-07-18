require 'rails_helper'

describe Study do
  let!(:study) { Study.new({xml: Nokogiri::XML(File.read(Rails.root.join('spec',
                                                          'support',
                                                          'xml_data',
                                                          'example_study.xml'))), nct_id: 'NCT00002475'}).create }

  describe '.create_derived_values' do
    it 'should create a derived value record for each study' do
      Study.create_derived_values

      expect(DerivedValue.count).to eq(1)
    end
  end

  describe 'with_related_records' do
    subject { study }
    it { is_expected.to respond_to 'with_related_records'}
    it { is_expected.to respond_to 'with_related_records=' }

    it 'should allow the with_related_records attribute to be set' do
      expect(study.with_related_records).not_to be true
      study.with_related_records = true
      expect(study.with_related_records).to be true
    end
  end
end
