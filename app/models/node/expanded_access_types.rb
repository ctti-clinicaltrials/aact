module Node
  class ExpandedAccessTypes < Node::Base
    attr_accessor :exp_acc_type_individual, :exp_acc_type_intermediate, :exp_acc_type_treatment

    def process(root)
      byebug
      root.study.expanded_access_type_individual = get_boolean(exp_acc_type_individual)
      root.study.expanded_access_type_intermediate = get_boolean(exp_acc_type_intermediate)
      root.study.expanded_access_type_treatment = get_boolean(exp_acc_type_treatment)
    end
  end
end