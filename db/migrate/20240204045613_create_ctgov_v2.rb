class CreateCtgovV2 < ActiveRecord::Migration[6.0]
  def up
    execute File.read('db/ctgov_v2.sql')
  end

  def down
    execute <<-SQL
      DROP SCHEMA ctgov_v2 CASCADE;
    SQL
  end
end
