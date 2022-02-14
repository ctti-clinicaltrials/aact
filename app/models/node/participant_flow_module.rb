module Node
  class ParticipantFlowModule < Node::Base
    attr_accessor :flow_recruitment_details, :flow_pre_assignment_details

    attr_accessor :flow_group_list

    def process(root)
      root.participant_flow = ParticipantFlow.new(
        recruitment_details: flow_recruitment_details,
        pre_assignment_details: flow_pre_assignment_details
      )

      flow_group_list.process(root) if flow_group_list
    end
  end
end