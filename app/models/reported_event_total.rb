class ReportedEventTotal < ApplicationRecord
    def self.mapper(json)
        adverse_events_module = json.dig('adverseEventsModule')
        return [] unless adverse_events_module
        event_groups = adverse_events_module.dig('eventGroups')
        return [] unless event_groups

        event_groups.each do |event_group|
            collection << event_totals('seriousEvents', event_group)
            collection << event_totals('otherEvents', event_group)
            # collection << event_totals('Deaths', event_group)
        end
        collection
        # ask Ramiro about nct id, deaths, AACT-620 and common correctness
    end
end
