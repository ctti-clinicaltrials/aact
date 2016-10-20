class OutcomeSerializer < ActiveModel::Serializer
  attributes :outcome_type,
      :title,
      :description,
      :measure,
      :time_frame,
      :safety_issue,
      :population,
      :participant_count,
      :anticipated_posting_month_year

  def attributes
    super.merge(other_attributes)
  end

  def other_attributes
    {}
  end
end
