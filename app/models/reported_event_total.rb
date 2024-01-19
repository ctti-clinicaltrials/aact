class ReportedEventTotal < ApplicationRecord
    def self.mapper(json)
        nct_id = json.dig('protocolSection')['identificationModule']['nctId']
        adverse_events_module = json.dig('adverseEventsModule')
        return [] unless adverse_events_module
        event_groups = adverse_events_module.dig('eventGroups')
        return [] unless event_groups

        # collection = []

        total_death_count = 0
        event_groups.each do |event_group|
          total_death_count += event_group['deathsNumAffected'] if event_group['deathsNumAffected']
        end
        deaths = {
          total_count: total_death_count,
          classification: 'Total, all-cause mortality'
        }
        collection = {
          nct_id: nct_id,
          deaths: deaths,
          seriousEvents: event_totals('serious', adverse_events_module),
          otherEvents: event_totals('other', adverse_events_module)
        }
        # ask Ramiro about nct id, deaths, AACT-620 and common correctness
        # add event_totals method 
        # deaths should be counted separately
    end

    def event_totals(event_type='serious', adverse_events_module)
        event_hash = adverse_events_module.dig("#{event_type}Events")
        return {} if event_hash.empty?
    
        if event_type == 'serious'
          classification = 'Total, serious adverse events'
        elsif event_type == 'other'
          classification = 'Total, other adverse events'
        else
          classification = ''
        end
        {
          total_count: event_hash.length,
          classification: classification
        }
      end

      #OLD
# [
#   {
#       nct_id: nct_id,
#       ctgov_group_code: event_hash['EventGroupId'],
#       event_type: "Serious",
#       classification: classification,
#       subjects_affected: event_hash["EventGroup#{event_type}NumAffected"],
#       subjects_at_risk: event_hash["EventGroup#{event_type}NumAtRisk"]
#     },
#     {
#       nct_id: nct_id,
#       ctgov_group_code: event_hash['EventGroupId'],
#       event_type: "Other",
#       classification: classification,
#       subjects_affected: event_hash["EventGroup#{event_type}NumAffected"],
#       subjects_at_risk: event_hash["EventGroup#{event_type}NumAtRisk"]
#     },
#     {
#       nct_id: nct_id,
#       ctgov_group_code: event_hash['EventGroupId'],
#       event_type: "Deaths",
#       classification: classification,
#       subjects_affected: event_hash["EventGroup#{event_type}NumAffected"],
#       subjects_at_risk: event_hash["EventGroup#{event_type}NumAtRisk"]
#     }
# ]


# NEW
# [
#   nctid: 555,
#   deaths: {
#       total_count: 5,
#       classification: 'Total, all-cause mortality'},
#   seriousEvents: {
#       total_count: 5,
#       classification: 'Total, serious adverse events'},
#   otherEvents: {
#       total_count: 5,
#       classification: 'Total, other adverse events'}
# ]

end
