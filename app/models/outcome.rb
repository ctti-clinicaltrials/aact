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
        { name: :anticipated_posting_date, value: :anticipatedPostingDate, convert_to: :date_first_of_month },
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
            { name: :non_inferiority_type, value: :nonInferiorityType },
            { name: :non_inferiority_description, value: :nonInferiorityComment },
            { name: :param_type, value: :paramType },
            { name: :param_value, value: :paramValue },
            { name: :dispersion_type, value: :dispersionType },
            { name: :dispersion_value, value: :dispersionValue },
            { name: :p_value_modifier, value: :pValue, convert_to: ->(val) { val&.gsub(/[\d.-]/, '')&.strip } },
            { name: :p_value, value: :pValue, convert_to: ->(val) { val&.gsub(/[<> =]/, '')&.strip } },
            { name: :p_value_raw, value: :pValue },
            { name: :p_value_description, value: :pValueComment },
            { name: :ci_n_sides, value: :ciNumSides },
            { name: :ci_percent, value: :ciPctValue, convert_to: :float },
            { name: :ci_lower_limit, value: :ciLowerLimit, convert_to: :float },
            { name: :ci_upper_limit, value: :ciUpperLimit, convert_to: :float },
            { name: :ci_lower_limit_raw, value: :ciLowerLimit },
            { name: :ci_upper_limit_raw, value: :ciUpperLimit },
            { name: :ci_upper_limit_na_comment, value: :ciUpperLimitComment },
            { name: :method, value: :statisticalMethod },
            { name: :method_description, value: :statisticalComment },
            { name: :estimate_description, value: :estimateComment },
            { name: :groups_description, value: :groupDescription },
            { name: :other_analysis_description, value: :otherAnalysisDescription }
          ]
        }
      ]
    }
  end
end
