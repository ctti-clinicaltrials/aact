class CreateReviewsTable < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
			t.integer  :rating
			t.text     :comment
			t.string   :nct_id
			t.string   :user_id
			t.datetime :created_at
			t.datetime :updated_at
		end

	  add_index "reviews", ["nct_id"], name: "index_reviews_on_nct_id", using: :btree
	  add_index "reviews", ["user_id"], name: "index_reviews_on_user_id", using: :btree
	end
end
