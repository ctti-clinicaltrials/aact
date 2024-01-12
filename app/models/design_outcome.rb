class DesignOutcome < ApplicationRecord
  # attr_accessor :type

  # def self.create_all_from(options={})
  #   nct_id=options[:nct_id]
  #   primary=options[:xml].xpath("//primary_outcome").collect{|xml|
  #     create_from({:xml=>xml,:type=>'primary',:nct_id=>nct_id})}

  #   secondary=options[:xml].xpath("//secondary_outcome").collect{|xml|
  #     create_from({:xml=>xml,:type=>'secondary',:nct_id=>nct_id})}

  #   other=options[:xml].xpath("//other_outcome").collect{|xml|
  #     create_from({:xml=>xml,:type=>'other',:nct_id=>nct_id})}
  #   import(primary + secondary + other)
  # end

  # def attribs
  #   {
  #     :measure => get('measure'),
  #     :time_frame => get('time_frame'),
  #     :description => get('description'),
  #     :population => get('population'),
  #     :outcome_type => get_opt(:type)
  #   }
  # end

  def self.mapper(json)
    return unless json.protocol_section

    primary_outcomes = outcome_list('primaryOutcomes')
    secondary_outcomes = outcome_list('secondaryOutcomes')
    other_outcomes = outcome_list('otherOutcomes')
    primary_outcomes ||= []
    secondary_outcomes ||= []
    other_outcomes ||= []
    total = primary_outcomes + secondary_outcomes + other_outcomes
    return nil if total.empty?

    total
  end

  def outcome_list(outcome_type='primaryOutcomes')
    outcomes = json.protocol_section['outcomesModule']
    return unless outcomes

    nct_id = json.protocol_section.dig('identificationModule', 'nctId')

    collection = []
    outcomes.each do |outcome|
      collection << {
                      nct_id: nct_id,
                      outcome_type: outcome_type.downcase,
                      measure: outcome["#{outcome_type}measure"],
                      time_frame: outcome["#{outcome_type}timeFrame"],
                      population: nil,
                      description: outcome["#{outcome_type}description"]
                    }
    end
    collection
  end

end
