class ChangeColumnTypeInStudies < ActiveRecord::Migration[6.0]
  def up
    change_column 'ctgov_v2.studies', :delayed_posting, 'boolean USING CAST(delayed_posting AS boolean)'
    add_column 'ctgov_v2.studies', :patient_registry, :boolean
  end

  def down
    remove_column 'ctgov_v2.studies', :patient_registry
    change_column 'ctgov_v2.studies', :delayed_posting, 'text USING CAST(delayed_posting AS text)'
  end
end
