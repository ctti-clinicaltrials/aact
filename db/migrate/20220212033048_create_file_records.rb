class CreateFileRecords < ActiveRecord::Migration[6.0]
  def change
    create_table 'support.file_records', if_not_exists: true do |t|
      t.string :filename
      t.bigint :file_size
      t.string :file_type

      t.timestamps
    end
  end
end
