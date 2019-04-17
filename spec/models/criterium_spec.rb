require 'rails_helper'

RSpec.describe Criterium, type: :model do
  context 'when criteria provided' do

    it 'should parse inclusion section and save each one' do
      described_class.destroy_all
      nct_id='NCT03599518'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      opts={xml: xml, nct_id: nct_id}
      described_class.create_all_from(opts)

      inclusion = described_class.where(criteria_type: 'inclusion')
      exclusion = described_class.where(criteria_type: 'exclusion')
      expect(inclusion.size).to eq(12)
      expect(exclusion.size).to eq(23)
      sample=inclusion.first
      expect(sample.name).to eq('has histologically or cytologically documented adenocarcinoma nsclc')
      expect(sample.order_number).to eq(1)
    end
  end

end
