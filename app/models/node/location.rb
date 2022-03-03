module Node
  class Location < Node::Base
    attribute :location_country

    def process(root)
      root.countries << Country.new(
        nct_id: root.study.nct_id,
        name: location_country,
        removed: false
      )
    end
  end
end