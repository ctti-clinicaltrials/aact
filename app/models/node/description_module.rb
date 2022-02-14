module Node
  class DescriptionModule < Node::Base
    attr_accessor :detailed_description, :brief_summary

    def process(root)
      root.detailed_description = DetailedDescription.new(
        nct_id: root.study.nct_id,
        description: detailed_description
      )

      root.brief_summary = BriefSummary.new(
        nct_id: root.study.nct_id,
        description: brief_summary
      )
    end
  end
end