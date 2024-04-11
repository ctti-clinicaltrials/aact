class Outcome < StudyRelationship
  has_many :outcome_counts, inverse_of: :outcome, autosave: true
  has_many :outcome_analyses, inverse_of: :outcome, autosave: true
  has_many :outcome_measurements, inverse_of: :outcome, autosave: true

  add_mapping do
    {
      table: :outcomes,
      root: [:resultsSection, :outcomeMeasuresModule, :outcomeMeasures],
      columns: [
        { name: :outcome_type, value: :type },
        { name: :title, value: :title },
        { name: :description, value: :description },
        { name: :time_frame, value: :timeFrame },
        { name: :population, value: :populationDescription },
        { name: :anticipated_posting_date, value: :anticipatedPostingDate, convert_to: :date },
        { name: :anticipated_posting_month_year, value: :anticipatedPostingDate },
        { name: :units, value: :unitOfMeasure },
        { name: :units_analyzed, value: :typeUnitsAnalyzed },
        { name: :dispersion_type, value: :dispersionType },
        { name: :param_type, value: :paramType },
      ],
      children: [
        {
          table: :outcome_analyses,
          root: [:analyses],
          columns: [
            { name: :outcome_id, value: nil },
            { name: :non_inferiority_type, value: nil },
            { name: :non_inferiority_description, value: nil },
            { name: :param_type, value: nil },
            { name: :param_value, value: nil },
            { name: :dispersion_type, value: nil },
            { name: :dispersion_value, value: nil },
            { name: :p_value_modifier, value: nil },
            { name: :p_value, value: nil },
            { name: :p_value_raw, value: nil },
            { name: :p_value_description, value: nil },
            { name: :ci_n_sides, value: nil },
            { name: :ci_percent, value: nil },
            { name: :ci_lower_limit, value: nil },
            { name: :ci_upper_limit, value: nil },
            { name: :ci_lower_limit_raw, value: nil },
            { name: :ci_upper_limit_raw, value: nil },
            { name: :ci_upper_limit_na_comment, value: nil },
            { name: :method, value: nil },
            { name: :method_description, value: nil },
            { name: :estimate_description, value: nil },
            { name: :groups_description, value: nil },
            { name: :other_analysis_description, value: nil }
          ]
        }
      ]
    }
  end
end
