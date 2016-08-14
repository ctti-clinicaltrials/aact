class OutcomeGroup < StudyRelationship
  extend FastCount
  belongs_to :outcome, inverse_of: :outcome_groups, autosave: true
  belongs_to :result_group, inverse_of: :outcome_groups, autosave: true

  def self.create_all_from(hash)
    return [] if hash[:groups].empty?
    hash[:groups].collect{|g| new({:outcome=>hash[:outcome],:result_group=>g}) }
  end
end
