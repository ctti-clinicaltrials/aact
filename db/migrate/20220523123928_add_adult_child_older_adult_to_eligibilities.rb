class AddAdultChildOlderAdultToEligibilities < ActiveRecord::Migration[6.0]
  def change
    add_column :eligibilities, :adult, :boolean
    add_column :eligibilities, :child, :boolean
    add_column :eligibilities, :older_adult, :boolean
  end
end
