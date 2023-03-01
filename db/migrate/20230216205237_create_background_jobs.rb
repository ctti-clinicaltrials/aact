class CreateBackgroundJobs < ActiveRecord::Migration[6.0]
  def change
    create_table :background_jobs do |t|
      t.integer :user_id
      t.string :status
      t.timestamp :completed_at
      t.string :logs
      t.string :type
      t.json :data
      t.string :url

      t.timestamps
    end
  end
end
