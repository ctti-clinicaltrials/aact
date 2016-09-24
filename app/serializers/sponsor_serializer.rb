class SponsorSerializer < ActiveModel::Serializer
  attributes :nct_id,
      :agency_class,
      :lead_or_collaborator,
      :name

  def attributes
    super.merge(other_attributes)
  end

  def other_attributes
    {}
  end
end
