module Node
  class ConditionList < Node::Base
    attr_accessor :conditions

    def process(root)
      conditions.each do |condition|
        root.conditions << Condition.new(
          nct_id: root.study.nct_id,
          name: condition,
          downcase_name: condition.downcase
        )
      end
    end
  end
end