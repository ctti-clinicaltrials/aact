class RemoveDeprecatedDates < ActiveRecord::Migration
  def change

    remove_column :studies, :first_received_date
    remove_column :studies, :last_changed_date
    remove_column :studies, :first_received_results_date
    remove_column :studies, :received_results_disposit_date

  end
end
