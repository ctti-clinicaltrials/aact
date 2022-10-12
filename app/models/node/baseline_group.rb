module Node
  class BaselineGroup < Node::Base
    attr_accessor :baseline_group_id, :baseline_group_title, :baseline_group_description
    def process(root)
      root.result_groups << ResultGroup.new(
        nct_id: root.study.nct_id,
        ctgov_group_code: baseline_group_id,
        result_type: 'Baseline',
        title: baseline_group_title,
        description: baseline_group_description
      )
    end
  end
end