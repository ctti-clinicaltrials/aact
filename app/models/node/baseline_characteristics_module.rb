module Node
  class BaselineCharacteristicsModule < Node::Base
    attr_accessor :baseline_population_description

    attr_accessor :baseline_group_list
    
    def process(root)
      root.study.baseline_population = baseline_population_description

      baseline_group_list.process(root) if baseline_group_list
    end
  end
end