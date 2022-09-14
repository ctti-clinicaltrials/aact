module Node
  class DesignInfo < Node::Base
    attr_accessor :design_allocation, :design_intervention_model, :design_intervention_model_description, :design_primary_purpose

    attr_accessor :design_observational_model_list, :design_time_perspective_list, :design_masking_info

    def process(root)
      root.design = Design.new(
        nct_id: root.study.nct_id,
        allocation: design_allocation,
        intervention_model: design_intervention_model,
        intervention_model_description: design_intervention_model_description,
        primary_purpose: design_primary_purpose,
      )

      design_observational_model_list.process(root) if design_observational_model_list
      design_time_perspective_list.process(root) if design_time_perspective_list
      design_masking_info.process(root) if design_masking_info
    end
  end
end