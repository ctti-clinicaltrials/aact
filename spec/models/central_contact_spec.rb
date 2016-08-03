require 'rails_helper'

RSpec.describe CentralContact, type: :model do
  context 'when central contact exists' do
    let!(:xml) {Nokogiri::XML(File.read('spec/support/xml_data/NCT02830269.xml'))}
    let!(:opts) {{xml: xml, nct_id: 'NCT02830269'}}
    let!(:central_contact) {CentralContact.create_all_from(opts)}

    it 'should have expected primary contact values' do

      contact_type_primary = CentralContact.where(contact_type: 'primary').first

      expect(contact_type_primary.contact_type).to eq('primary')
      expect(contact_type_primary.name).to eq('GERALD GERALD, MD, Ph D')
      expect(contact_type_primary.phone).to eq('+33467337271')
      expect(contact_type_primary.email).to eq('g-chanques@chu-montpellier.fr')
      expect(contact_type_primary.nct_id).to eq('NCT02830269')

    end

    it 'should have expected backup contact values' do

      contact_type_backup = CentralContact.where(contact_type: 'backup').first

      expect(contact_type_backup.contact_type).to eq('backup')
      expect(contact_type_backup.name).to eq('Pierre-François PERRIGAULT, MD')
      expect(contact_type_backup.phone).to eq('+33467337271')
      expect(contact_type_backup.email).to eq('pf-perrigault@chu-montpellier.fr')
      expect(contact_type_backup.nct_id).to eq('NCT02830269')
    end
  end


end
