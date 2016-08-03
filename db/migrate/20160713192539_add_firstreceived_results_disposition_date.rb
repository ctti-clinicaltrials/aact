class AddFirstreceivedResultsDispositionDate < ActiveRecord::Migration
  def change
    add_column :studies, :first_received_results_disposition_date, :date
  end
end
