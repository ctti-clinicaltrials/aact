class ReportedEvent < StudyRelationship
  belongs_to :result_group

  add_mapping do
    [
      {
        table: :reported_events,
        root: [:resultsSection, :adverseEventsModule],
        flatten: [:seriousEvents, :stats],
        requires: :result_groups,
        columns: [
          { name: :result_group_id, value: reference(:result_groups)[:groupId, 'Reported Event'] },
          { name: :event_type, value: 'serious' },
          
          # resultsSection -> adverseEventsModule 
          { name: :time_frame, value: [:$parent, :$parent, :timeFrame] },
          { name: :frequency_threshold, value: [:$parent, :$parent, :frequencyThreshold] },
          { name: :description, value: [:$parent, :$parent, :description] },

          # resultsSection -> adverseEventsModule -> seriousEvents
          { name: :adverse_event_term, value: [:$parent, :term] },
          { name: :organ_system, value: [:$parent, :organSystem] },
          { name: :vocab, value: [:$parent, :sourceVocabulary] },
          { name: :assessment, value: [:$parent, :assessmentType] },

          # resultsSection -> adverseEventsModule -> seriousEvents -> stats -> { group results }
          { name: :ctgov_group_code, value: :groupId },
          { name: :event_count, value: :numEvents },
          { name: :subjects_affected, value: :numAffected },
          { name: :subjects_at_risk, value: :numAtRisk },
        ]
      },
      {
        table: :reported_events,
        root: [:resultsSection, :adverseEventsModule],
        flatten: [:otherEvents, :stats],
        requires: :result_groups,
        columns: [
          { name: :result_group_id, value: reference(:result_groups)[:groupId, 'Reported Event'] },
          { name: :event_type, value: 'other' },
          
          # resultsSection -> adverseEventsModule 
          { name: :time_frame, value: [:$parent, :$parent, :timeFrame] },
          { name: :frequency_threshold, value: [:$parent, :$parent, :frequencyThreshold] },
          { name: :description, value: [:$parent, :$parent, :description] },

          # resultsSection -> adverseEventsModule -> otherEvents
          { name: :adverse_event_term, value: [:$parent, :term] },
          { name: :organ_system, value: [:$parent, :organSystem] },
          { name: :vocab, value: [:$parent, :sourceVocabulary] },
          { name: :assessment, value: [:$parent, :assessmentType] },

          # resultsSection -> adverseEventsModule -> otherEvents -> stats -> { group results }
          { name: :ctgov_group_code, value: :groupId },
          { name: :event_count, value: :numEvents },
          { name: :subjects_affected, value: :numAffected },
          { name: :subjects_at_risk, value: :numAtRisk },
        ]
      }
    ]
  end
end
