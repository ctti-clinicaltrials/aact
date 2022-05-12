class AddPhoneExtToFacilityContacts < ActiveRecord::Migration[6.0]
  def change
    add_column :facility_contacts, :phone_extension, :string
  end
end
