class CreateIndices < ActiveRecord::Migration

  def change
    add_index :study_xml_records, :nct_id
    add_index :sanity_checks, :created_at
    add_index :sanity_checks, :most_current
    add_index :sanity_checks, :table_name
    add_index :study_xml_records, :created_study_at
  end

end
