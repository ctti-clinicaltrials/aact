class CreateVerifiers < ActiveRecord::Migration[6.0]
  def change
    create_table :verifiers do |t|

      t.timestamps
    end
  end
end
