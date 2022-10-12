module Node
  class StartDateStruct < Node::Base
    attr_accessor :start_date, :start_date_type

    def process(root)
      root.study.start_month_year = start_date
      root.study.start_date_type = start_date_type
      root.study.start_date = convert_date(start_date)
    end
  end
end