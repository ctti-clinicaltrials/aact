module Node
  class PhaseList < Node::Base
    attr_accessor :phases

    def process(root)
      root.study.phase = phases.join('/')
    end
  end
end