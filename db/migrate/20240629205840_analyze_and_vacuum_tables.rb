class AnalyzeAndVacuumTables < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def up
    execute "ANALYZE calculated_values"
    execute "VACUUM ANALYZE calculated_values"
    execute "ANALYZE outcomes"
    execute "VACUUM ANALYZE outcomes"
  end

  def down
    # No need to revert
  end
end

