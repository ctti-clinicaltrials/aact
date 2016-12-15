class OutcomeGroup < StudyRelationship
  belongs_to :outcome, inverse_of: :outcome_groups, autosave: true
  belongs_to :result_group, inverse_of: :outcome_groups, autosave: true

  def self.create_all_from(hash)
    return [] if hash[:groups].empty?
    hash[:groups].collect{|g| new({:nct_id=>hash[:nct_id],:outcome=>hash[:outcome],:result_group=>g,:ctgov_group_code=>g.ctgov_group_code}) }
  end
end
