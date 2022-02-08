module Node
  class EnrollmentInfo < Node::Base
    attr_accessor :enrollment_count, :enrollment_type

    def process(root)
      root.study.enrollment = enrollment_count
      root.study.enrollment_type = enrollment_type
    end
  end
end