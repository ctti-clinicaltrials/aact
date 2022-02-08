module Node
  class ArmGroupList < Node::Base
    attr_accessor :arm_groups

    def process(root)
      # interventional studies use arms, while observational studies use groups
      if root.study.study_type =~ /Interventional/i
        root.study.number_of_arms = arm_groups.length
      else
        root.study.number_of_groups = arm_groups.length
      end
    end
  end
end