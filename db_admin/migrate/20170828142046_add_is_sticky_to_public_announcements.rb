class AddIsStickyToPublicAnnouncements < ActiveRecord::Migration
  def change
    add_column :public_announcements, :is_sticky, :boolean
  end
end
