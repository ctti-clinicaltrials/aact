module Node
  class LastUpdatePostDateStruct < Node::Base
    attr_accessor :last_update_post_date, :last_update_post_date_type

    def process(root)
      root.study.last_update_posted_date = get_date(last_update_post_date)
      root.study.last_update_posted_date_type = last_update_post_date_type
    end
  end
end