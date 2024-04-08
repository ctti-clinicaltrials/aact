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
      ]
    }
  end
end
