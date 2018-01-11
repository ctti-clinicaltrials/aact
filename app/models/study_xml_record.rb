class StudyXmlRecord < Admin::AdminBase
  belongs_to :study, foreign_key: "nct_id"

  def self.not_yet_loaded(study_filter=nil)
    if study_filter
      where('created_study_at is null and nct_id like ?',"%#{study_filter}")
    else
      where('created_study_at is null')
    end
  end

end
