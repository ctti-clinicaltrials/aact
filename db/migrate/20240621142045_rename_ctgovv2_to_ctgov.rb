class RenameCtgovv2ToCtgov < ActiveRecord::Migration[6.0]
  def up
    execute "ALTER SCHEMA ctgov_v2 RENAME TO ctgov"
  end

  def down
    execute "ALTER SCHEMA ctgov RENAME TO ctgov_v2"
  end
end
