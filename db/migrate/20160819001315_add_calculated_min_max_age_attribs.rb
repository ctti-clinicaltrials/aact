class AddCalculatedMinMaxAgeAttribs < ActiveRecord::Migration
  def change
    add_column  :calculated_values, :has_minimum_age, :boolean
    add_column  :calculated_values, :has_maximum_age, :boolean
    add_column  :calculated_values, :minimum_age_num, :integer
    add_column  :calculated_values, :maximum_age_num, :integer
    add_column  :calculated_values, :minimum_age_unit, :string
    add_column  :calculated_values, :maximum_age_unit, :string
  end
end
