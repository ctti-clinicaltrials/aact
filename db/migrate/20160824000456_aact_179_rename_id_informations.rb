class Aact179RenameIdInformations < ActiveRecord::Migration
  def change
    drop_table :id_informations
    create_table :id_information do |t|
      t.string :nct_id
      t.string :id_type
      t.string :id_value
    end
  end
end
