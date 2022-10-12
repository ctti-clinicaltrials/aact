module Node
  class ArmGroup < Node::Base
    attribute :arm_group_type, :arm_group_label, :arm_group_description

    def process(root)
      root.design_groups << DesignGroup.new(
        nct_id: root.study.nct_id,
        group_type: arm_group_type,
        title: arm_group_label,
        description: arm_group_description
      )
    end
  end
end