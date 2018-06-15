class AddRemovedUsers < ActiveRecord::Migration
  def change
    create_table(:removed_users) do |t|
      t.string   :email
      t.string   :encrypted_password
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer  :sign_in_count
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
      t.string   :first_name
      t.string   :last_name
      t.string   :username
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.timestamps null: false
    end

    add_index :removed_users, :email, unique: false
    add_index :removed_users, :username, unique: false

    add_index :users, :username, unique: true
  end

end
