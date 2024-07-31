class ReportedEvent < StudyRelationship
  belongs_to :result_group

  scope :events_subject_count, -> (nct_ids) {
    where(nct_id: nct_ids)
    .group(:nct_id, :event_type)
    .sum(:subjects_affected)
  }

  add_mapping do
    [
      {
        table: :reported_events,
        root: [:resultsSection, :adverseEventsModule],
        flatten: [:seriousEvents, :stats],
        # requires outcomes to be loaded first, otherwise events are being processed twice
        requires: [:result_groups, :outcomes],
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

  def self.sum_subjects_by_event_type_for(nct_ids)
    counts = ReportedEvent.events_subject_count(nct_ids)

    nct_ids.each_with_object({}) do |nct_id, organized_sums|
      organized_sums[nct_id] = {
        serious: counts[[nct_id, 'serious']],
        other: counts[[nct_id, 'other']]
      }
    end
  end
end
