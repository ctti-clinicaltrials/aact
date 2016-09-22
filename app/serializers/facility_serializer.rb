class FacilitySerializer < ActiveModel::Serializer
  attributes :nct_id,
             :name,
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
