module Node
  class RemovedCountryList < Node::Base
    attr_accessor :removed_countries

    def process(root)
      removed_countries.each do |country|
        root.countries << Country.new(
          nct_id: root.study.nct_id,
          name: country,
          removed: true
        )
      end
    end
  end
end