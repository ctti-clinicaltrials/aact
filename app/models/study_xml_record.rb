class StudyXmlRecord < ActiveRecord::Base
  has_one :study, foreign_key: "nct_id"
end
