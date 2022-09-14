module Node
  class StudyFirstPostDateStruct < Node::Base
    attr_accessor :study_first_post_date, :study_first_post_date_type

    def process(root)
      root.study.study_first_posted_date = get_date(study_first_post_date)
      root.study.study_first_posted_date_type = study_first_post_date_type
    end
  end
end