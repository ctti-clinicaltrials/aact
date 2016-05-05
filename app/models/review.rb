class Review < ActiveRecord::Base

  belongs_to :user
  belongs_to :study, :foreign_key => 'nct_id'
  validates :rating, :comment, presence: true
end
