require 'rails_helper'

describe SanityCheck do
  describe '.save_row_counts' do

    before do
      nct_id='NCT00023673'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      study=Study.new({xml: xml, nct_id: nct_id}).create
      CalculatedValue.new.create_from(study).save!
      SanityCheck.save_row_counts
    end

    it 'should have one row for each study-related table' do
      expect(SanityCheck.count).to eq(43)
    end

    it 'should have row count 1 for each table that has 1-to-1 relationship with studies table' do
      ClinicalTrials::Updater.single_study_tables.each{|table_name|
         rows=SanityCheck.where('table_name=?',table_name)
         expect(rows.size).to eq(1)
         row=rows.first
         expect(row.row_count).to eq(1)
      }
    end

  end
end
