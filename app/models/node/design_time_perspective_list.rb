module Node
  class DesignTimePerspectiveList < Node::Base
    attr_accessor :design_time_perspectives

    def process(root)
      root.design.time_perspective = design_time_perspectives.join(", ")
    end
  end
end