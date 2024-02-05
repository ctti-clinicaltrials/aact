class ChangeColumnTypeInStudies < ActiveRecord::Migration[6.0]
  def change
    change_column :studies, :delayed_posting, 'boolean USING CAST(delayed_posting AS boolean)'
  end
end
