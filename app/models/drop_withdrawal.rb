class DropWithdrawal < StudyRelationship
  belongs_to :result_group

  add_mapping do
    {
      table: :drop_withdrawals,
      root: [:resultsSection, :participantFlowModule, :periods],
      flatten: [:dropWithdraws, :reasons],
      requires: :result_groups,
      columns: [
        { name: :result_group_id, value: reference(:result_groups)[:groupId, 'Participant Flow'] },
        { name: :ctgov_group_code, value: :groupId },
        { name: :period, value: [:$parent, :$parent, :title] },
        { name: :reason, value: [:$parent, :type] },
        { name: :count, value: :numSubjects },
        { name: :drop_withdraw_comment, value: [:$parent, :comment] || 'No comment' },
        { name: :reason_comment, value: :comment || 'No reason comment provided' },
        { name: :count_units, value: :numUnits || 'units not specified' }
        # { name: :drop_withdraw_comment, value: [:$parent, :comment] },
        # { name: :reason_comment, value: :comment },
        # { name: :count_units, value: :numUnits }
      ]
    }
  end
end