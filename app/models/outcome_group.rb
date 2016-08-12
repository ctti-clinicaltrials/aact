class OutcomeGroup < StudyRelationship
  extend FastCount
  belongs_to :outcome, inverse_of: :outcome_groups, autosave: true
  belongs_to :result_group, inverse_of: :outcome_groups, autosave: true

  def self.create_all_from(package)
    outcome=package[:outcome]
    groups=package[:groups]
    return [] if groups.empty?
    groups.collect{|g| new({:outcome=>outcome,:result_group=>g}) }
  end
end
