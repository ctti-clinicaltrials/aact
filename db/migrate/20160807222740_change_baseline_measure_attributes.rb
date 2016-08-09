class ChangeBaselineMeasureAttributes < ActiveRecord::Migration
  def change

    add_column :baseline_measures, :population, :string

    remove_column :baseline_measures, :ctgov_group_enumerator, :integer
    remove_column :baseline_measures, :ctgov_group_id, :string
    add_column    :baseline_measures, :ctgov_group_code, :string
    add_column    :baseline_measures, :group_id, :integer, references: :groups

    remove_column :baseline_measures, :param, :string
    add_column    :baseline_measures, :param_type, :string

    remove_column :baseline_measures, :measure_value, :string
    add_column    :baseline_measures, :param_value, :string

    remove_column :baseline_measures, :dispersion, :string
    add_column    :baseline_measures, :dispersion_type, :string

    remove_column :baseline_measures, :spread, :string
    add_column    :baseline_measures, :dispersion_value, :string

    remove_column :baseline_measures, :lower_limit, :string
    add_column    :baseline_measures, :dispersion_lower_limit, :string

    remove_column :baseline_measures, :upper_limit, :string
    add_column    :baseline_measures, :dispersion_upper_limit, :string

    remove_column :baseline_measures, :measure_description, :string
    add_column    :baseline_measures, :explanation_of_na, :string
  end
end
