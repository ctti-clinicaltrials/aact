module Node
  class BioSpec < Node::Base
    attr_accessor :bio_spec_description, :bio_spec_retention
    def process(root)
      root.study.biospec_retention = bio_spec_retention
      root.study.biospec_description = bio_spec_description
    end
  end
end