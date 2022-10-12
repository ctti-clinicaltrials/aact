module Node
  class DesignModule < Node::Base
    attr_accessor :target_duration, :study_type, :patient_registry

    attr_accessor :phase_list, :enrollment_info, :expanded_access_types, :bio_spec, :design_info

    def process(root)
      root.study.target_duration = target_duration
      if patient_registry =~ /Yes/i
        root.study.study_type = "#{study_type} [Patient Registry]"
      else
        root.study.study_type = study_type
      end

      phase_list.process(root) if phase_list
      enrollment_info.process(root) if enrollment_info
      expanded_access_types.process(root) if expanded_access_types
      bio_spec.process(root) if bio_spec
      design_info.process(root) if design_info
    end
  end
end