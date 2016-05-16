class EditLoadEvents < ActiveRecord::Migration
  def change
    add_column :load_events, :completed_at, :datetime
    remove_column :load_events, :nct_id
    remove_column :load_events, :load_time
  end
end
