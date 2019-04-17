require 'rails_helper'

RSpec.describe Criteria, type: :model do
  context 'when criteria provided' do

    it 'should parse inclusion section and save each one' do
      Criteria.destroy_all
      nct_id='NCT03599518'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      opts={xml: xml, nct_id: nct_id}
      Criteria.create_all_from(opts)

      inclusion = Criteria.where(criteria_type: 'inclusion')
      exclusion = Criteria.where(criteria_type: 'exclusion')
      expect(inclusion.size).to eq(12)
      expect(exclusion.size).to eq(23)
      sample=inclusion.first
      #expect(inclusion.name).to eq('1. Has histologically or cytologically documented adenocarcinoma NSCLC')
    end
  end

end
