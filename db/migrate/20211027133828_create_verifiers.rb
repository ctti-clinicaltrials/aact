class CreateVerifiers < ActiveRecord::Migration[6.0]
  def change
    create_table :verifiers do |t|
      t.json :differences, null: false, default: []
      t.timestamp :last_run

      t.timestamps
    end
  end
end
