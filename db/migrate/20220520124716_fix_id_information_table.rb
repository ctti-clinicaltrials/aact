class FixIdInformationTable < ActiveRecord::Migration[6.0]
  def change
    rename_column :id_information, :id_type, :id_source
    add_column :id_information, :id_type, :string
    add_column :id_information, :id_type_description, :string
    add_column :id_information, :id_link, :string
  end
end
