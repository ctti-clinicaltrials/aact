require 'rails_helper'
RSpec.describe Study do
    it "should have expected values" do
      nct_id='NCT02260193'
			c=ClinicalTrials::Client.new(search_term: nct_id)
			VCR.use_cassette 'get_NCT02260193' do
			  c.download_xml_files
			end
			c.populate_studies
			study=Study.where('nct_id=?',nct_id).first
      expect(study.first_received_results_disposition_date).to eq('October 23, 2015'.to_date)
  end
end

