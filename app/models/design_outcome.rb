class DesignOutcome < ApplicationRecord
 
  def self.mapper(json)
    return unless json.protocol_section

    primary_outcomes = outcome_list(json, 'primaryOutcomes')
    secondary_outcomes = outcome_list(json, 'secondaryOutcomes')
    other_outcomes = outcome_list(json, 'otherOutcomes')
    primary_outcomes ||= []
    secondary_outcomes ||= []
    other_outcomes ||= []
    total = primary_outcomes + secondary_outcomes + other_outcomes
    return nil if total.empty?
    
    total
  end

  def self.outcome_list(json, outcome_type='primaryOutcomes')
    outcomes = json.protocol_section.dig('outcomesModule', outcome_type)
    return unless outcomes

    nct_id = json.protocol_section.dig('identificationModule', 'nctId')

    collection = []
    outcomes.each do |outcome|
      collection << {
                      nct_id: nct_id,
                      outcome_type: outcome_type.downcase,
                      measure: outcome['measure'],
                      time_frame: outcome['timeFrame'],
                      population: nil,
                      description: outcome['description']
                    }
    end

    collection
  end

end
