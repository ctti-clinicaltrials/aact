class CreateCtgovSchema < ActiveRecord::Migration

  def up
    execute <<-SQL
      create schema ctgov;
      alter role ctti set search_path to ctgov, public;
      grant create on schema ctgov to ctti;
      grant usage on schema ctgov to public;
      grant select on all tables in schema ctgov to public;
    SQL
  end

  def down
    execute <<-SQL
      drop schema if exists ctgov cascade;
    SQL
  end

end
