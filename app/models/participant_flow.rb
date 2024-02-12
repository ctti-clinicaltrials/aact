class ParticipantFlow < StudyRelationship
  add_mapping do
    {
      table: :participant_flows,
      root: [:resultsSection, :participantFlowModule],
      columns: [
        {name: :recruitment_details, value: :recruitmentDetails},
        {name: :pre_assignment_details, value: :preAssignmentDetails},
        {name: :units_analyzed, value: :typeUnitsAnalyzed}
      ]
    }
  end
end
