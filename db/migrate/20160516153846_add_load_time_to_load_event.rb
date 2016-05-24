class AddLoadTimeToLoadEvent < ActiveRecord::Migration
  def change
    add_column :load_events, :load_time, :string
  end
end
