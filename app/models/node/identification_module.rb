module Node
  class IdentificationModule < Node::Base
    attr_accessor :nct_id, :acronym, :brief_title, :official_title

    attr_accessor :organization

    def process(root)
      root.study.nct_id = nct_id
      root.study.acronym = acronym
      root.study.brief_title = brief_title
      root.study.official_title = official_title

      organization.process(root)
    end
  end
end