module Node
  class Phase < Node::Base
    def initialize(data, root)
      @data = data
    end

    def process(root)
      root.study.phase = @data.join('/')
    end
  end
end