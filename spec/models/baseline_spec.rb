require 'rails_helper'

describe BaselineMeasurement do
  it 'should test baseline_measurements_data' do
    expected_data = {
      nct_id: 'NCT04431453',
      result_group_id: '75939068',
      ctgov_group_code: 'BG000',
      classification: 'Behavior',
      category: 'Score: 0',
      title: 'Pediatric Early Warning Score (PEWS) Scale Score',
      description: 'Behavior:0=playing;appropriate;1=sleeping;2=irritable;3=lethargic;confused;reduced response to pain. Cardiovascular:0=normal;pink;capillary refill(cr)1-2 seconds(secs);1=Tachycardia\\< 20 above normal for age;2=Tachycardia 20-29 above normal for age;gray;cr=4 secs;3=Tachycardia \\>=30 above/bradycardia \\>=10 below normal for age;Gray;cr\\>=5 secs.Respiratory:0=Normal;1=Respiratory rate(rr)\\>10 above normal using accessory muscles;30+%fraction of inspired oxygen(FiO2)/3+L/min;2= rr\\>20 above normal and retractions;40%FiO2 or 6+L/min;3 =rr\\>=5 below normal with retractions and grunting;50%FiO2/8+L/min.',
      units: 'Participants',
      param_type: 'COUNT_OF_PARTICIPANTS',
      param_value: '7',
      param_value_num: '7.0',
      dispersion_type: nil,
      dispersion_value: nil,
      dispersion_value_num: nil,
      dispersion_lower_limit: nil,
      dispersion_upper_limit: nil,
      explanation_of_na: nil,
      number_analyzed: '12',
      number_analyzed_units: nil,
      population_description: "Data for Cohorts 6 and 7 are not reported due to participants' confidentiality reasons as there was only 1 participant in each of these groups.",
      calculate_percentage: 'No'
    }

    hash = JSON.parse(File.read('spec/support/json_data/NCT04431453.json'))
    json = StudyJsonRecord::ProcessorV2.new(hash)
    result = BaselineMeasurement.mapper(json)

    expect(result.first).to eq(expected_data)
  end
end
