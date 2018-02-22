class AddOutcomesAnticipatedPostingsDate < ActiveRecord::Migration
  def change
    add_column :outcomes, :anticipated_posting_date, :date
  end

end
