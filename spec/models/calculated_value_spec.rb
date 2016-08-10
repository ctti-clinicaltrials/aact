require 'rails_helper'

RSpec.describe CalculatedValue, type: :model do
  context 'when study exists' do
    it 'should have expected dates and calculated values' do

      nct_id='NCT00482794'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      study=Study.new({xml: xml, nct_id: nct_id}).create

      expect(study.first_received_date).to eq('June 1, 2007'.to_date)
      expect(study.last_changed_date).to eq('October 23, 2015'.to_date)
      expect(study.start_date_month_day).to eq('June 2006')
      expect(study.verification_date_month_day).to eq('October 2015')
      expect(study.primary_completion_date_month_day).to eq('July 2016')
      expect(study.completion_date_month_day).to eq('July 2016')
      expect(study.nlm_download_date_description).to eq('ClinicalTrials.gov processed this data on June 27, 2016')

      expect(study.calculated_value.nct_id).to eq(nct_id)
      expect(study.calculated_value.start_date).to eq('June 2006'.to_date)
      expect(study.calculated_value.verification_date).to eq('October 2015'.to_date)
      expect(study.calculated_value.completion_date).to eq('July 2016'.to_date)
      expect(study.calculated_value.primary_completion_date).to eq('July 2016'.to_date)
      expect(study.calculated_value.nlm_download_date).to eq('June 27, 2016'.to_date)
    end
  end
end
