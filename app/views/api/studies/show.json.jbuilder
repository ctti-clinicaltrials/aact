json.study do
  json.merge! @study.attributes

  if @related_records == "true"
    json.facilities @study.facilities do |facility|
      json.merge! facility.attributes
    end

    json.sponsors @study.sponsors do |sponsor|
      json.merge! sponsor.attributes
    end
  end
end
