class BaselineMeasurement < ApplicationRecord

  belongs_to :result_group

  def self.mapper(json)
    return unless json.results_section
    nct_id = json.protocol_section.dig('identificationModule', 'nctId')

    measure = json.results_section.dig('baselineCharacteristicsModule', 'measures')
    baseline_group = json.results_section.dig('baselineCharacteristicsModule')
    result_groups = create_and_group_results(baseline_group, 'Baseline', 'Baseline')
    return unless measure

    collection = { baseline_counts: baseline_counts_data, measurements: [] }

    measure.each do |measure|
      baseline_classes = measure.dig('classes')
      next unless baseline_classes

      baseline_classes.each do |baseline_class|
        baseline_categories = json.baseline_class.dig('categories')
        next unless baseline_categories

        baseline_categories.each do |baseline_category|
          measurements = json.baseline_category.dig('measurements')
          next unless measurements

          measurements.each do |measurement|
            param_value = measurement['value']
            dispersion_value = measurement['spread']
            ctgov_group_code = measurement['groupId']
            denoms = results_section.dig('baselineCharacteristicsModule', 'denoms')
            denom = denoms.find { |k| k['BaselineDemonUnits'] == measurement['BaselineDenomUnitsSelected'] }
            counts = denom.dig('counts')
            count = counts.find { |k| k['groupId'] == ctgov_group_code }

            collection[:measurements] << {
              nct_id: nct_id,
              result_group_id: result_groups[ctgov_group_code].try(:id),
              ctgov_group_code: ctgov_group_code,
              classification: baseline_class['title'],
              category: baseline_category['title'],
              title: measure['title'],
              description: measure['description'],
              units: measure['unitOfMeasure'],
              param_type: measure['paramType'],
              param_value: param_value,
              param_value_num: StudyJsonRecord.float(param_value),
              dispersion_type: measure['dispersionType'],
              dispersion_value: dispersion_value,
              dispersion_value_num: StudyJsonRecord.float(dispersion_value),
              dispersion_lower_limit: StudyJsonRecord.float(measurement['lowerLimit']),
              dispersion_upper_limit: StudyJsonRecord.float(measurement['upperLimit']),
              explanation_of_na: measurement['comment'],
              number_analyzed: count['value'],
              number_analyzed_units: measure['denomUnitsSelected'],
              population_description: measure['populationDescription'],
              calculate_percentage: measure['calculatePct']
            }
          end
        end
      end
    end
    collection
  end
end
