class ChangeColumnTypeInStudies < ActiveRecord::Migration[6.0]
  def change
    change_column 'ctgov_v2.studies', :delayed_posting, 'boolean USING CAST(delayed_posting AS boolean)'
  end
end
