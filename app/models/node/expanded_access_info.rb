module Node
  class ExpandedAccessInfo < Node::Base
    attr_accessor :has_expanded_access

    def process(root)
      root.study.has_expanded_access = get_boolean(has_expanded_access)
    end
  end
end