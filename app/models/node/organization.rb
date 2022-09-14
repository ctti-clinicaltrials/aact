module Node
  class Organization < Node::Base
    attr_accessor :org_full_name

    def process(root)
      root.study.source = org_full_name
    end
  end
end