class RenameCtgovToLegacy < ActiveRecord::Migration[6.0]
  def up
    execute "ALTER SCHEMA ctgov RENAME TO legacy"
  end

  def down
    execute "ALTER SCHEMA legacy RENAME TO ctgov"
  end
end
