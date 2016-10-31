class CreateIndices < ActiveRecord::Migration

  def change

    add_index :browse_conditions, :nct_id
    add_index :browse_interventions, :nct_id
    add_index :overall_officials, :nct_id
    add_index :responsible_parties, :nct_id
    add_index :studies, :nct_id
    add_index :study_xml_records, :nct_id

    add_index :browse_conditions, :mesh_term
    add_index :browse_interventions, :mesh_term
    add_index :facilities, :name
    add_index :overall_officials, :affiliation
    add_index :responsible_parties, :organization
    add_index :studies, :source
    add_index :study_xml_records, :created_study_at

  end

end
