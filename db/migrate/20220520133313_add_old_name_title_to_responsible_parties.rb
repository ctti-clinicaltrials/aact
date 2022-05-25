class AddOldNameTitleToResponsibleParties < ActiveRecord::Migration[6.0]
  def change
    add_column :responsible_parties, :old_name_title, :string
  end
end
