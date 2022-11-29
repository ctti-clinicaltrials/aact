module Node
  class DesignWhoMaskedList < Node::Base
    attr_accessor :design_who_maskeds

    def process(root)
      root.design.subject_masked = (design_who_maskeds & ['Subject','Participant']).length > 0
      root.design.caregiver_masked = (design_who_maskeds & ['Caregiver','Care Provider']).length > 0
      root.design.investigator_masked = (design_who_maskeds & ['Investigator']).length > 0
      root.design.outcomes_assessor_masked = (design_who_maskeds & ['Outcomes Assessor']).length > 0
    end
  end
end