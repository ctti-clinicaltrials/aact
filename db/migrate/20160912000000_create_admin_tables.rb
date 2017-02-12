class CreateAdminTables < ActiveRecord::Migration

  def change

    create_table :data_definitions do |t|
      t.string 'db_section'
      t.string 'table_name'
      t.string 'column_name'
      t.string 'data_type'
      t.string 'source'
      t.text   'ctti_note'
      t.string 'nlm_link'
      t.integer 'row_count'
      t.json   'enumerations'
      t.timestamps null: false
    end

#    execute <<-SQL
      #CREATE USER aact WITH PASSWORD 'aact';
#      GRANT SELECT ON ALL TABLES IN SCHEMA public TO aact;
#    SQL
  end

end
