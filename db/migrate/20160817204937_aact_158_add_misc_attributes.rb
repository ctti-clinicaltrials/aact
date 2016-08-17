class Aact158AddMiscAttributes < ActiveRecord::Migration
  def change
    add_column :responsible_parties, :organization, :string
    add_column :outcomes, :anticipated_posting_month_year, :string
    add_column :outcome_analyses, :p_value_description, :string
  end
end
