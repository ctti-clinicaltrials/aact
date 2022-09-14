module Node
  class BaselineGroupList < Node::Base
    attr_accessor :baseline_groups

    def process(root)
      if baseline_groups
        baseline_groups.each do |group|
          group.process(root)
        end
      end
    end
  end
end