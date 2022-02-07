class CreateFileRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :file_records do |t|
      t.string :filename
      t.bigint :file_size
      t.string :file_type
      t.string :string

      t.timestamps
    end
  end
end
