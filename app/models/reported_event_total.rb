class ReportedEventTotal < StudyRelationship

  add_mapping do
    [
      {
        table: :reported_event_totals,
        root: [:resultsSection, :adverseEventsModule, :eventGroups],
        columns: [
          { name: :ctgov_group_code, value: :id },
          { name: :event_type, value: 'serious' },
          { name: :classification, value: 'Total, serious adverse events' },
          { name: :subjects_affected, value: :seriousNumAffected },
          { name: :subjects_at_risk, value: :seriousNumAtRisk }

        ]
      },
      {
        table: :reported_event_totals,
        root: [:resultsSection, :adverseEventsModule, :eventGroups],
        columns: [
          { name: :nct_id, value: :nct_id },
          { name: :ctgov_group_code, value: :id },
          { name: :event_type, value: 'other' },
          { name: :classification, value: 'Total, other adverse events' },
          { name: :subjects_affected, value: :otherNumAffected },
          { name: :subjects_at_risk, value: :otherNumAtRisk }
        ]
      },
      {
        table: :reported_event_totals,
        root: [:resultsSection, :adverseEventsModule, :eventGroups],
        columns: [
          { name: :nct_id, value: :nct_id },
          { name: :ctgov_group_code, value: :id },
          { name: :event_type, value: 'deaths' },
          { name: :classification, value: 'Total, all-cause mortality'},
          { name: :subjects_affected, value: :deathsNumAffected },
          { name: :subjects_at_risk, value: :deathsNumAtRisk }
        ]
      }
    ]
  end
end
