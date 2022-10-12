module Node
  class EventGroup < Node::Base
    attr_accessor :event_group_id, :event_group_title, :event_group_description

    def process(root)
      root.result_groups << ResultGroup.new(
        nct_id: root.study.nct_id,
        ctgov_group_code: event_group_id,
        result_type: 'Reported Event',
        title: event_group_title,
        description: event_group_description
      )
    end
  end
end