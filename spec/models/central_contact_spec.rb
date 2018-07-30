require 'rails_helper'

RSpec.describe CentralContact, type: :model do
  context 'when central contact exists' do

    it 'should have expected primary contact values' do
      CentralContact.destroy_all
      nct_id='NCT02830269'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      opts={xml: xml, nct_id: nct_id}
      CentralContact.create_all_from(opts)

      primary_contacts = CentralContact.where(contact_type: 'primary')
      expect(primary_contacts.size).to eq(1)
      sample=primary_contacts.first
      expect(sample.name).to eq('GERALD CHANQUES, MD, Ph D')
      expect(sample.contact_type).to eq('primary')
      expect(sample.phone).to eq('+33467337271')
      expect(sample.email).to eq('g-chanques@chu-montpellier.fr')
      expect(sample.nct_id).to eq('NCT02830269')

      backups = CentralContact.where(contact_type: 'backup')
      expect(backups.size).to eq(1)
      sample=backups.select{|c| c.name=='Pierre-François PERRIGAULT, MD'}.first
      expect(sample.contact_type).to eq('backup')
      expect(sample.phone).to eq('+33467337271')
      expect(sample.email).to eq('pf-perrigault@chu-montpellier.fr')
      expect(sample.nct_id).to eq('NCT02830269')
    end
  end

end
