class OutcomeGroup < StudyRelationship
  extend FastCount
  belongs_to :result_group, inverse_of: :outcome_groups, autosave: true
  belongs_to :outcome, inverse_of: :outcome_groups, autosave: true

  def attribs
    {
      :outcome           => get_opt('outcome'),
      :result_group      => get_group(opts[:groups]),
      :ctgov_group_code  => get_attribute('group_id'),
      :participant_count => get_attribute('value'),
    }
  end

end
