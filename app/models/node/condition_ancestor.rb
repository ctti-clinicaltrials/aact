module Node
  class ConditionAncestor < Node::Base
    attr_accessor :condition_ancestor_term

    def process(root)
      root.browse_conditions << BrowseCondition.new(
        nct_id: root.study.nct_id,
        mesh_term: condition_ancestor_term,
        downcase_mesh_term: condition_ancestor_term.downcase,
        mesh_type: 'mesh-ancestor'
      )
    end
  end
end