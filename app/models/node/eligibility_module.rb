module Node
  class EligibilityModule < Node::Base
    attr_accessor :sampling_method, :study_population, :maximum_age, :minimum_age, :gender,
                  :gender_based, :gender_description, :healthy_volunteers, :eligibility_criteria

    def process(root)
      root.eligibility = Eligibility.new(
        nct_id: root.study.nct_id,
        sampling_method: sampling_method,
        population: study_population,
        maximum_age: maximum_age || 'N/A',
        minimum_age: minimum_age || 'N/A',
        gender: gender,
        gender_based: get_boolean(gender_based),
        gender_description: gender_description,
        healthy_volunteers: healthy_volunteers,
        criteria: eligibility_criteria
      )
    end
  end
end