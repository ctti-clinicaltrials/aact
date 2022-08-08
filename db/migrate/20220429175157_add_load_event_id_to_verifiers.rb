class AddLoadEventIdToVerifiers < ActiveRecord::Migration[6.0]
  def change
    add_column :verifiers, :load_event_id, :integer unless column_exists? :verifiers, :load_event_id, :integer
  end
end
