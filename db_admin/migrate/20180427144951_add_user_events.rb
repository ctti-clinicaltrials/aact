class AddUserEvents < ActiveRecord::Migration
  def change

    create_table "user_events", force: :cascade do |t|
      t.string   "email"
      t.string   "event_type"
      t.text     "description"
      t.timestamps null: false
    end

  end
end
