class CreateCriteriaTable < ActiveRecord::Migration

  def change

    create_table "ctgov.criteria", force: :cascade do |t|
      t.string  "nct_id"
      t.string  "criteria_type"
      t.string  "name"
    end

  end

end
