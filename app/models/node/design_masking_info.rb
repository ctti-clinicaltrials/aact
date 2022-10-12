module Node
  class DesignMaskingInfo < Node::Base
    attr_accessor :design_masking, :design_masking_description

    attr_accessor :design_who_masked_list

    def process(root)
      root.design.masking = design_masking
      root.design.masking_description = design_masking_description
      # default values
      root.design.subject_masked = false
      root.design.caregiver_masked = false
      root.design.investigator_masked = false
      root.design.outcomes_assessor_masked = false

      design_who_masked_list.process(root) if design_who_masked_list
    end
  end
end