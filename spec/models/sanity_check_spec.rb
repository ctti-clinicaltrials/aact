require 'rails_helper'

describe SanityCheck do
  describe '.run' do
    let(:sanity_check) { SanityCheck.last }
    let!(:study) { Study.new({xml: Nokogiri::XML(File.read(Rails.root.join('spec',
                                                                          'support',
                                                                          'xml_data',
                                                                          'example_study.xml'))), nct_id: 'NCT00002475'}).create }


    before do
      SanityCheck.run
    end

    it 'should create a sanity check record with the correct row counts' do
      expect(sanity_check.present?).to eq(true)
      expect(sanity_check.report.studies.present?).to eq(true)
      expect(sanity_check.report.studies.row_count).to eq(1)
      expect(sanity_check.report.conditions.row_count).to eq(6)
      expect(sanity_check.report.design_outcomes.row_count).to eq(5)
    end

    it 'should create a sanity check record with the correct column length information' do
      expect(sanity_check.report.studies.column_stats.present?).to eq(true)
      expect(sanity_check.report.studies.column_stats.nct_id.max).to eq(11)
      expect(sanity_check.report.studies.column_stats.nct_id.min).to eq(11)
      expect(sanity_check.report.studies.column_stats.nct_id.avg).to eq(11)
    end
  end
end
