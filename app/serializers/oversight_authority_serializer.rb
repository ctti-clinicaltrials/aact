class OversightAuthoritySerializer < ActiveModel::Serializer
  attributes :name

  def attributes
    super.merge(other_attributes)
  end

  def other_attributes
    {}
  end
end
