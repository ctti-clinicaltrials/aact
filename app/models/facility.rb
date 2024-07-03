class Facility < StudyRelationship
  has_many :facility_contacts
  has_many :facility_investigators

  # Scope to return nct_ids with a single facility - currently not used
  scope :nct_ids_with_single_facility, ->(nct_ids) {
    where(nct_id: nct_ids).group(:nct_id).having('count(*) = 1').pluck(:nct_id)
  }

  # Scope to return facility counts for given nct_ids
  scope :facility_counts, ->(nct_ids) {
    where(nct_id: nct_ids).group(:nct_id).count
  }

  # Scope to return nct_ids with facilities in the US
  scope :us_facility_nct_ids, ->(nct_ids) {
    where(nct_id: nct_ids, country: us_territories).distinct.pluck(:nct_id)
  }


  add_mapping do
    {
      table: :facilities,
      root: [:protocolSection, :contactsLocationsModule, :locations],
      columns: [
        { name: :status, value: :status },
        { name: :name, value: :facility },
        { name: :city, value: :city },
        { name: :state, value: :state },
        { name: :zip, value: :zip },
        { name: :country, value: :country },
      ],
      children: [
        {
          table: :facility_investigators,
          root: [:contacts],
          filter: ->(contact) { contact['role'] =~ /investigator|study.chair/i },
          columns: [
            { name: :role, value: :role },
            { name: :name, value: :name },
          ]
        },
        {
          table: :facility_contacts,
          root: [:contacts],
          filter: ->(contact) { contact['role'] !~ /investigator|study.chair/i },
          columns: [
            { name: :contact_type, value: ->(entry,index){ index == 0 ? 'primary' : 'backup' }},
            { name: :name, value: :name },
            { name: :email, value: :email },
            { name: :phone, value: :phone },
            { name: :phone_extension, value: :phoneExt },
          ]
        }
      ]
    }
  end

  
  private

  # TODO: logic from previous implementation - how to optimize?
  def self.us_territories
    [
      'United States', 'Guam', 'Puerto Rico', 'U.S. Virgin Islands',
      'Virgin Islands (U.S.)', 'Northern Mariana Islands', 'American Samoa',
      'Midway Atoll', 'Palmyra Atoll', 'Baker Island', 'Howland Island',
      'Jarvis Island', 'Johnston Atoll', 'Kingman Reef', 'Wake Island',
      'Navassa Island', 'Serranilla Bank', 'Bajo Nuevo Bank'
    ]
  end
end
