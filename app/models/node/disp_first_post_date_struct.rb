module Node
  class DispFirstPostDateStruct < Node::Base
    attr_accessor :disp_first_post_date, :disp_first_post_date_type

    def process(root)
      root.study.disposition_first_posted_date = get_date(disp_first_post_date)
      root.study.disposition_first_posted_date_type = disp_first_post_date_type
    end
  end
end