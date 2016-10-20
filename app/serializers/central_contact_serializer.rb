class CentralContactSerializer < ActiveModel::Serializer
  attributes :contact_type,
             :name,
             :phone,
             :email

  def attributes
    super.merge(other_attributes)
  end

  def other_attributes
    {}
  end
end
