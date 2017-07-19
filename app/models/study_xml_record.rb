class StudyXmlRecord < AdminBase
  belongs_to :study, foreign_key: "nct_id"

  def self.not_yet_loaded
    where('created_study_at is null')
  end

end
