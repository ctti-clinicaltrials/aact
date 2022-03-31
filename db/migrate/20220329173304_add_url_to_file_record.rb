class AddUrlToFileRecord < ActiveRecord::Migration[6.0]
  def change
    add_column :file_records, :url, :string
  end
end
