class CreateVerifiers < ActiveRecord::Migration[6.0]
  def change
    create_table 'support.verifiers', if_not_exists: true do |t|
      t.json :differences, null: false, default: []
      t.timestamp :last_run
      t.json :source

      t.timestamps
    end
  end
end
