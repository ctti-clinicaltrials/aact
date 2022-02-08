module Node
  class DesignModule < Node::Base
    attr_accessor :target_duration, :study_type, :patient_registry

    attr_accessor :phase_list, :enrollment_info

    def process(root)
      root.study.target_duration = target_duration
      if patient_registry =~ /Yes/i
        root.study.study_type = "#{study_type} [Patient Registry]"
      else
        root.study.study_type = study_type
      end

      phase_list.process(root) if phase_list
      enrollment_info.process(root) if enrollment_info
    end
  end
end