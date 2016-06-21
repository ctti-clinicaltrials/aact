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

end
