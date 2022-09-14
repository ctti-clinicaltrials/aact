module Node
  class OutcomeGroup < Node::Base
    attr_accessor :outcome_group_id, :outcome_group_title, :outcome_group_description

    def process(root)
      root.result_groups << ResultGroup.new(
        nct_id: root.study.nct_id,
        ctgov_group_code: outcome_group_id,
        result_type: 'Outcome',
        title: outcome_group_title,
        description: outcome_group_description
      )
    end
  end
end