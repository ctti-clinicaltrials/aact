module Node
  class FlowGroup < Node::Base
    attr_accessor :flow_group_id, :flow_group_title, :flow_group_description

    def process(root)
      root.result_groups << ResultGroup.new(
        nct_id: root.study.nct_id,
        ctgov_group_code: flow_group_id,
        result_type: 'Participant Flow',
        title: flow_group_title,
        description: flow_group_description
      )
    end
  end
end