class AddOrganizationToResponsibleParty < ActiveRecord::Migration
  def change
    add_column :responsible_parties, :organization, :string
  end
end
