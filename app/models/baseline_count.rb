class BaselineCount < StudyRelationship

  belongs_to :result_group

  add_mapping do
    {
      table: :baseline_counts,
      root: [:resultsSection, :baselineCharacteristicsModule],
      flatten: ['denoms','counts'],
      requires: :result_groups,
      columns: [
        { name: :result_group_id, value: reference(:result_groups)[:groupId, 'Baseline'] },
        { name: :ctgov_group_code, value: :groupId },
        { name: :units, value: [:$parent, :units] },
        { name: :scope, value: 'overall' }, # not in json - same value for all records in db
        { name: :count, value: :value }
      ]
    }
  end
end
