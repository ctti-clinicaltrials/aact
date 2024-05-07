class BaselineMeasurement < StudyRelationship

  belongs_to :result_group

  add_mapping do
      {
        table: :baseline_measurements,
        root: [:resultsSection, :baselineCharacteristicsModule],
        flatten: [:measures, :classes, :categories, :measurements],
        requires: :result_groups,
        columns: [
          { name: :result_group_id, value: reference(:result_groups)[:groupId, "Baseline"] },
          { name: :ctgov_group_code, value: :groupId },

          { name: :classification, value: [:$parent, :$parent, :title] }, # class.title - optional if 1+ class
          { name: :category, value: [:$parent, :title] }, # category.title - optional if 1+ category
          
          { name: :title, value: [:$parent, :$parent, :$parent, :title] }, # measure.title required
          { name: :description, value: [:$parent, :$parent, :$parent, :description] }, # measure.description optional
          { name: :units, value: [:$parent, :$parent, :$parent, :unitOfMeasure] }, # measure.unitOfMeasure required
          { name: :population_description, value: [:$parent, :$parent, :$parent, :populationDescription] }, # measure.populationDescription optional

          { name: :calculate_percentage,
            value: [:$parent, :$parent, :$parent, :calculatePct],
            convert_to: ->(val) { val.nil? ? nil : (val == false ? "No" : "Yes") }
          }, # measure.calculatePct optional

          # TODO: Use Enumns to humanize values (ex. COUNT_OF_PARTICIPANTS" to "Count of Participants")
          { name: :param_type, value: [:$parent, :$parent, :$parent, :paramType] }, # measure.paramType required
          { name: :param_value, value: :value }, # measurement.value
          { name: :param_value_num, value: :value, convert_to: :float }, # measurement.value

          # TODO: Use Enumns to humanize values (ex. "STANDARD_DEVIATION" to "Standard Deviation")
          { name: :dispersion_type, value: [:$parent, :$parent, :$parent, :dispersionType] }, # measure.dispersionType required
          { name: :dispersion_value, value: :spread }, # measurement.spread
          { name: :dispersion_value_num, value: :spread, convert_to: :float },
          { name: :dispersion_lower_limit, value: :lowerLimit, convert_to: :float  }, # measurement.lowerLimit 
          { name: :dispersion_upper_limit, value: :upperLimit, convert_to: :float  }, # measurement.upperLimit
          { name: :explanation_of_na, value: :comment}, # measurement.comment

          { name: :number_analyzed, value: nil, convert_to: ->(val) { BaselineMeasurement.number_analyzed(val) }},
          { name: :number_analyzed_units,
            value: [:$parent, :$parent, :$parent, :denomUnitsSelected],
            convert_to: ->(val) { val.nil? ? "Participants" : val } # TODO: avoid hardcoding
          }
        ]
      }
    end

    private

    def self.number_analyzed(measurement)
      group_id = measurement["groupId"]
      denom_units = measurement["$parent"]["$parent"]["$parent"]["denomUnitsSelected"]

      # If denom_units is not present, check at the top level
      # TODO: Find a way to avoid accessing Database
      if denom_units.nil?
        baseline_count = BaselineCount.find_by(ctgov_group_code: group_id)
        return baseline_count&.count
      end

      # check class denoms or measure denoms
      denoms = measurement["$parent"]["$parent"]["denoms"] || measurement["$parent"]["$parent"]["$parent"]["denoms"]
      raise "Error: class or measure denoms is nil" if denoms.nil?

      denoms.find do |denom|
        if denom["units"] == denom_units
          denom["counts"].find do |count|
            return count["value"] if count["groupId"] == group_id
          end
        end
      end
    end
end
