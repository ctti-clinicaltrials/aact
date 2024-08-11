
class IdInformation < StudyRelationship
  self.table_name = 'id_information'

  add_mapping do
    [
      {
        table: :id_information,
        root: [:protocolSection, :identificationModule, :nctIdAliases],
        columns: [
          { name: :id_source, value: 'nct_alias' },
          { name: :id_value, value: nil }
        ]
      },
      {
        table: :id_information,
        root: [:protocolSection, :identificationModule, :orgStudyIdInfo],
        columns: [
          { name: :id_source, value: 'org_study_id' },
          { name: :id_type, value: :type },
          { name: :id_type_description, value: :domain },
          { name: :id_link, value: :link },
          { name: :id_value, value: :id}
        ]
      },
      {
        table: :id_information,
        root: [:protocolSection, :identificationModule, :secondaryIdInfos],
        columns: [
          { name: :id_source, value: 'secondary_id' },
          { name: :id_value, value: :id },
          { name: :id_type, value: :type },
          { name: :id_type_description, value: :domain },
          { name: :id_link, value: :link }
        ]
      }
    ]
  end
end