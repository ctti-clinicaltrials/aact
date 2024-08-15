class Outcome < StudyRelationship
  has_many :outcome_counts
  has_many :outcome_analyses
  has_many :outcome_measurements
  has_many :result_groups

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
        { name: :param_type, value: :paramType }
      ],
      children: [
        {
          table: :result_groups,
          root: [:groups],
          columns: [
            { name: :ctgov_group_code, value: :id },
            { name: :result_type, value: 'Outcome' },
            { name: :title, value: :title },
            { name: :description, value: :description }
          ]
        },
        {
          table: :outcome_measurements,
          # TODO: after removing dup values can update root to [:classes] to reduce object size
          root: nil, 
          flatten: [:classes, :categories, :measurements],
          columns: [
            # result_group_id is set by ResultGroup.set_outcome_results_group_ids
            { name: :ctgov_group_code, value: :groupId },
            { name: :classification, value: [:$parent, :$parent, :title] },
            { name: :category, value: [:$parent, :title] },
            { name: :title, value: [:$parent, :$parent, :$parent, :title] }, # TODO: remove duplication, we already store in parent
            { name: :description, value: [:$parent, :$parent, :$parent, :description] }, # TODO: remove duplication, we already store in parent
            { name: :units, value: [:$parent, :$parent, :$parent, :unitOfMeasure] }, # TODO: remove duplication, we already store in parent
            { name: :param_type, value: [:$parent, :$parent, :$parent, :paramType] }, # TODO: remove duplication, we already store in parent
            { name: :dispersion_type, value: [:$parent, :$parent, :$parent, :dispersionType] }, # TODO: remove duplication, we already store in parent
            { name: :param_value, value: :value },
            { name: :param_value_num, value: :value, convert_to: :float },
            { name: :dispersion_value, value: :spread },
            { name: :dispersion_value_num, value: :spread, convert_to: :float },
            { name: :dispersion_lower_limit_raw, value: :lowerLimit },
            { name: :dispersion_lower_limit, value: :lowerLimit, convert_to: :float },
            { name: :dispersion_upper_limit_raw, value: :upperLimit },
            { name: :dispersion_upper_limit, value: :upperLimit, convert_to: :float },
            { name: :explanation_of_na, value: :comment },
            # { name: :denom_units, value: [:$parent, :$parent, :$parent, :denoms, :units] }, # TODO: how do we navigate to that value in the JSON??
            # { name: :denom_value, value: [:$parent, :$parent, :$parent, :denoms, :counts, match(:groupId), :value] }, # TODO: how do we navigate to that value in the JSON??
          ]
        },
        { 
          table: :outcome_counts,
          root: [:denoms],
          flatten: [:counts],
          columns: [
            # result_group_id is set by ResultGroup.handle_outcome_result_groups_ids
            { name: :ctgov_group_code, value: [:groupId] },
            { name: :scope, value: 'Measure' },
            { name: :units, value: [:$parent, :units] },
            { name: :count, value: [:value] }

          ]
        },
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
          ],
          children: [
            {
              table: :outcome_analysis_groups,
              root: [:groupIds],
              columns: [
                # result_group_id is set by ResultGroup.handle_outcome_result_groups_ids
                { name: :ctgov_group_code, value: nil } # will be single ctgov_group_code from [:groupIds]
              ]
            }  
          ]       
        }
      ]
    }
  end
end
