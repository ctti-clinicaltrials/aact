class CreateSanityChecks < ActiveRecord::Migration
  def change
    create_table :sanity_checks do |t|
      t.text :report, null: false

      t.timestamps null: false
    end
  end
end
