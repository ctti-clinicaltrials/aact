module Node
  class DesignObservationalModelList < Node::Base
    attr_accessor :design_observational_models

    def process(root)
      root.design.observational_model = design_observational_models.join(", ")
    end
  end
end