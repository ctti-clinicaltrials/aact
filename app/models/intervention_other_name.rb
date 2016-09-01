class InterventionOtherName < StudyRelationship
  belongs_to :intervention, inverse_of: :intervention_other_names, autosave: true

  def self.top_level_label
    'other_name'
  end

  def attribs
    {
     :name=>opts[:xml].text,
     :intervention=>opts[:intervention]
    }
  end

end
