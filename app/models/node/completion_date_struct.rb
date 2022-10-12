module Node
  class CompletionDateStruct < Node::Base
    attr_accessor :completion_date, :completion_date_type

    def process(root)
      root.study.completion_month_year = completion_date
      root.study.completion_date_type = completion_date_type
      root.study.completion_date = convert_date(completion_date)
    end
  end
end