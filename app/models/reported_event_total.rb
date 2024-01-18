class ReportedEventTotal < ApplicationRecord
    def self.mapper(json)
        adverse_events_module = json.dig('adverseEventsModule')
        return [] unless adverse_events_module
        event_groups = adverse_events_module.dig('eventGroups')
        return [] unless event_groups


        event_groups.each do |event_group|
            collection << event_totals('seriousEvents', event_group)
            collection << event_totals('otherEvents', event_group)
            collection << event_totals('deathsNumAffected', event_group)
        end
        collection
        # ask Ramiro about nct id, deaths, AACT-620 and common correctness
        # add event_totals method 
        # deaths should be counted separately
    end

    def event_totals(event_type='Serious', event_hash={})
        return {} if event_hash.empty?
    
        if event_type == 'Serious'
          classification = 'Total, serious adverse events'
        elsif event_type == 'Other'
          classification = 'Total, other adverse events'
        elsif event_type == 'Deaths'
          classification = 'Total, all-cause mortality'
        else
          classification = ''
        end
        {
          nct_id: nct_id,
          ctgov_group_code: event_hash['id'],
          event_type: event_type.downcase,
          classification: classification,
          subjects_affected: event_hash["EventGroup#{event_type}NumAffected"],
          subjects_at_risk: event_hash["EventGroup#{event_type}NumAtRisk"]
        }
      end
end
