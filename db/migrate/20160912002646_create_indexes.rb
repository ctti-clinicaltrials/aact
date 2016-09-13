class CreateIndexes < ActiveRecord::Migration

  def change

#    Only create these after a full load - it significantly slows down the load when indexes exist
#    add_index "facilities", ["nct_id"], name: "index_facilities_on_nct_id", using: :btree
#    add_index "outcomes", ["nct_id"], name: "index_outcomes_on_nct_id", using: :btree
#    add_index "reported_events", ["event_type"], name: "index_reported_events_on_event_type", using: :btree
#    add_index "reported_events", ["nct_id"], name: "index_reported_events_on_nct_id", using: :btree
#    add_index "reported_events", ["subjects_affected"], name: "index_reported_events_on_subjects_affected", using: :btree
#    add_index "studies", ["nct_id"], name: "index_studies_on_nct_id", using: :btree

  end

end
