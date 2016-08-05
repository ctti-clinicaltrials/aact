class CreateCentralContacts < ActiveRecord::Migration
  def change
    create_table :central_contacts do |t|
      t.string :nct_id
      t.string :contact_type
      t.string :name
      t.string :phone
      t.string :email

      t.timestamps null: false
    end
  end
end
