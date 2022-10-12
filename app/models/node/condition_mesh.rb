module Node
  class ConditionMesh < Node::Base
    attr_accessor :condition_mesh_term

    def process(root)
      root.browse_conditions << BrowseCondition.new(
        nct_id: root.study.nct_id,
        mesh_term: condition_mesh_term,
        downcase_mesh_term: condition_mesh_term.downcase,
        mesh_type: 'mesh-list'
      )
    end
  end
end