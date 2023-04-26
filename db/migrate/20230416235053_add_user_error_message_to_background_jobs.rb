class AddUserErrorMessageToBackgroundJobs < ActiveRecord::Migration[6.0]
  def change
    add_column :background_jobs, :user_error_message, :string
  end
end
