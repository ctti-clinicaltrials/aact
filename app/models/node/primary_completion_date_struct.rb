module Node
  class PrimaryCompletionDateStruct < Node::Base
    attr_accessor :primary_completion_date, :primary_completion_date_type

    def process(root)
      root.study.primary_completion_month_year = primary_completion_date
      root.study.primary_completion_date = convert_date(primary_completion_date)
      root.study.primary_completion_date_type = primary_completion_date_type
    end
  end
end