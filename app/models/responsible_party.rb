class ResponsibleParty < StudyRelationship

  add_mapping do
    {
      table: :responsible_party,
      root: [:protocolSection, :sponsorCollaboratorsModule, :responsibleParty],
      columns: [
        { name: :responsible_party_type, value: :type },
        { name: :name, value: :investigatorFullName},
        { name: :title, value: :investigatorTitle},
        { name: :affiliation, value: :investigatorAffiliation },
        { name: :old_name_title, value: :oldNameTitle },
        { name: :organization, value: :oldOrganization},
      ]
    }
  end
end
