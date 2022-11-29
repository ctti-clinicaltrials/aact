module Node
  class ResultsFirstPostDateStruct < Node::Base
    attr_accessor :results_first_post_date, :results_first_post_date_type

    def process(root)
      root.study.results_first_posted_date = get_date(results_first_post_date)
      root.study.results_first_posted_date_type = results_first_post_date_type
    end
  end
end