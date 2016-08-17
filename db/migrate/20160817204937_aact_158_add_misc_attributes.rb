class Aact158AddMiscAttributes < ActiveRecord::Migration
  def change
    add_column :responsible_parties, :organization, :string
    add_column :outcomes, :anticipated_posting_month_year, :string
  end
end
