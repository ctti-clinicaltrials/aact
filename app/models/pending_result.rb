class PendingResult < ApplicationRecord
  enum unposted_event_type: {
    RELEASE: 'RELEASE',
    RESET: 'RESET',
    UNRELEASE: 'UNRELEASE'
  }

  def self.mapper(json)
    return unless json.annotation_section
    nct_id = json.protocol_section.dig('identificationModule', 'nctId')

    unposted_events = json.annotation_section.dig('annotationModule', 'unpostedAnnotation', 'unpostedEvents')
    return unless unposted_events

    collection = []
    unposted_events.each do |event|
      collection << {
        nct_id: nct_id,
        event: unposted_event_types[event['type']],
        event_date_description: event['date'],
        event_date: get_date(event['date'])
      }
    end
    collection
  end

  def self.get_date(str)
    begin
      str.try(:to_date)
    rescue
      nil
    end
  end
end
