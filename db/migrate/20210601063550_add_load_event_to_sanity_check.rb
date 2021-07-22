class AddLoadEventToSanityCheck < ActiveRecord::Migration[6.0]
  def change
    add_reference 'support.sanity_checks', :load_event, foreign_key: true
  end
end
