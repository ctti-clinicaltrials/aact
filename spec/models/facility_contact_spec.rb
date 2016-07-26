require 'rails_helper'

describe FacilityContact do
  let!(:facility_contact) { FacilityContact.new }

  describe '#sanitize_attribs' do
    it 'should return sanitized attribs hash' do
      facility_contact.attribs = {
        last_name: 'Garrett Martin',
        email: 'garrett@sturdy.work'
      }
      sanitized_attribs = facility_contact.sanitize_attribs(facility_contact.attribs)

      expect(sanitized_attribs.keys).not_to include('last_name')
      expect(sanitized_attribs.keys).to include('name')
    end
  end

end
