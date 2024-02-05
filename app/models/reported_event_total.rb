class ReportedEventTotal < ApplicationRecord
    def self.mapper(json)
        adverse_events_module = json.dig('adverseEventsModule')
        return [] unless adverse_events_module
        event_groups = adverse_events_module.dig('eventGroups')
        return [] unless event_groups

        nct_id = json.dig('protocolSection')['identificationModule']['nctId']
        collection = []

        event_groups.each do |event_group|
          collection << event_totals('serious', event_group, nct_id)
          collection << event_totals('other', event_group, nct_id)
          collection << event_totals('deaths', event_group, nct_id)
        end
        collection
    end

    def event_totals(event_type='serious', event_hash={}, nct_id)
      return {} if event_hash.empty?
  
      if event_type == 'serious'
        classification = 'Total, serious adverse events'
      elsif event_type == 'other'
        classification = 'Total, other adverse events'
      elsif event_type == 'deaths'
        classification = 'Total, all-cause mortality'
      else
        classification = ''
      end

      return {
        nct_id: nct_id,
        ctgov_group_code: event_hash['id']
        event_type: event_type,
        classification: classification,
        total_count: event_hash['deathsNumAffected'] ? event_hash['deathsNumAffected'] : 0
      } if event_type == 'deaths'
      {
        nct_id: nct_id,
        ctgov_group_code: event_hash['id'],
        event_type: event_type,
        classification: classification,
        subjects_affected: event_hash["#{event_type}NumAffected"],
        subjects_at_risk: event_hash["#{event_type}NumAtRisk"]
      }
    end

# [{
#       nct_id: nct_id,
#       ctgov_group_code: event_hash['EventGroupId'],
#       event_type: "Deaths",
#       classification: classification,
#       total_number: event_group['deathsNumAffected']
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
#       event_type: "Serious",
#       classification: classification,
#       subjects_affected: event_hash["EventGroup#{event_type}NumAffected"],
#       subjects_at_risk: event_hash["EventGroup#{event_type}NumAtRisk"]
# }, ...]

end
