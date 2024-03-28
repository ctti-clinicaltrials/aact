class Milestone < StudyRelationship
  belongs_to :result_group

  add_mapping do
    {
      table: :milestones,
      root: [:resultsSection, :participantFlowModule, :periods],
      flatten: [:milestones, :achievements],
      requires: :result_groups,
      columns: [
        { name: :result_group_id, value: reference(:result_groups)[:groupId, 'Participant Flow'] },
        { name: :ctgov_group_code, value: :groupId },
        { name: :title, value: [:$parent, :type] },
        { name: :period, value: [:$parent, :$parent, :title] },
        { name: :description, value: :description },
        { name: :count, value: :numSubjects },
        { name: :milestone_description, value: [:$parent, :comment] },
        { name: :count_units, value: :numUnits }
      ]
    }
  end
end
