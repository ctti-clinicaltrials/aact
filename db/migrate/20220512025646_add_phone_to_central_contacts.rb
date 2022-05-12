class AddPhoneToCentralContacts < ActiveRecord::Migration[6.0]
  def change
    add_column :central_contacts, :phone_extension, :string
    add_column :central_contacts, :role, :string
  end
end
