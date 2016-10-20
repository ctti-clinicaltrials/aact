class ResponsiblePartySerializer < ActiveModel::Serializer
  attributes :responsible_party_type,
      :affiliation,
      :organization,
      :title,
      :name

  def attributes
    super.merge(other_attributes)
  end

  def other_attributes
    {}
  end
end
