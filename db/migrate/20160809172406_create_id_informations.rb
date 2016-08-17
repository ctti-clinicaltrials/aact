class CreateIdInformations < ActiveRecord::Migration
  def change
    create_table :id_informations do |t|
      t.string :nct_id
      t.string :id_type
      t.string :id_value
    end
  end
end
