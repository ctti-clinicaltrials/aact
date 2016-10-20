class FacilitySerializer < ActiveModel::Serializer
  attributes :name,
             :status,
             :city,
             :state,
             :zip,
             :country

  def attributes
    super.merge(other_attributes)
  end

  def other_attributes
    {}
  end
end
