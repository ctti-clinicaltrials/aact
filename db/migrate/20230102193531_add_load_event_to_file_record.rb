class AddLoadEventToFileRecord < ActiveRecord::Migration[6.0]
  def change
    add_reference :file_records, :load_event, foreign_key: true
  end
end
