module Node
  class InterventionMesh < Node::Base
    attr_accessor :intervention_mesh_term

    def process(root)
      root.browse_interventions << BrowseIntervention.new(
        nct_id: root.study.nct_id,
        mesh_term: intervention_mesh_term,
        downcase_mesh_term: intervention_mesh_term.downcase,
        mesh_type: 'mesh-list'
      )
    end
  end
end