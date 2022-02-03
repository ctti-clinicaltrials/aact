class AddExtensionToResultContacts < ActiveRecord::Migration[6.0]
  def change
    add_column :result_contacts, :extension, :string
  end
end
