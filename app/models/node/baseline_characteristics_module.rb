module Node
  class BaselineCharacteristicsModule < Node::Base
    attr_accessor :baseline_population_description
    
    def process(root)
      root.study.baseline_population = baseline_population_description
    end
  end
end