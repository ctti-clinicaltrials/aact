class StudyXmlRecord < ActiveRecord::Base
  belongs_to :study, foreign_key: "nct_id"

  def self.not_yet_loaded
    where('created_study_at is null')
  end

  def was_created
    self.created_study_at=Time.now
    self.save!
  end
end
