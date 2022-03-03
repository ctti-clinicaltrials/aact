module Node
  class InterventionAncestor < Node::Base
    attr_accessor :intervention_ancestor_term

    def process(root)
      root.browse_interventions << BrowseIntervention.new(
        nct_id: root.study.nct_id,
        mesh_term: intervention_ancestor_term,
        downcase_mesh_term: intervention_ancestor_term.downcase,
        mesh_type: 'mesh-ancestor'
      )
    end
  end
end