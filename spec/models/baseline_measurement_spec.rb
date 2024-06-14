require "rails_helper"

describe "BaselineMeasurement and Baseline ResultGroup" do
  let(:nct_id) { "NCT000001" }

  json_files = [
    "baseline_measurements_1.json",
    "baseline_measurements_2.json",
    "baseline_measurements_3.json",
    "baseline_measurements_4.json",
    "baseline_measurements_5.json",
    "baseline_measurements_6.json"
  ]

  json_files.each do |json_file|
    context "When importing data from #{json_file}" do
      
      let(:content) { JSON.parse(File.read("spec/support/json_data/#{json_file}")) }

      before do
        @result_groups = content["resultsSection"]["baselineCharacteristicsModule"]["groups"]
        @measures = content["resultsSection"]["baselineCharacteristicsModule"]["measures"]
        @denoms = content["resultsSection"]["baselineCharacteristicsModule"]["denoms"]

        StudyJsonRecord.create(nct_id: nct_id, version: "2", content: content)
        StudyJsonRecord::Worker.new.process
      end

      describe "ResultGroup" do
        it "creates the correct number of records", schema: :v2 do
          expect(ResultGroup.count).to eq(@result_groups.count)
        end

        it "imports the data correctly", schema: :v2 do
          expected = expected_result_group_data.sort_by { |record| [record["ctgov_group_code"]] }
          expect(import_and_sort(ResultGroup)).to eq(expected)
        end
      end


      describe "BaselineCount" do
        it "creates the correct number of records", schema: :v2 do
          counts = @denoms.flat_map { |denom| denom["counts"] }
          expect(BaselineCount.count).to eq(counts.count)
        end
      end

      describe "BaselineMeasurement" do
        it "creates the correct number of records", schema: :v2 do
          measurement_count = @measures.sum do |measure|
            if measure["classes"].nil? || measure["classes"].empty?
              1 # Add one "empty" measurement per group
            else
              measure["classes"].sum do |measure_class|
                if measure_class["categories"].nil? || measure_class["categories"].empty?
                  1 # Add one "empty" measurement per class
                else
                  measure_class["categories"].sum do |category|
                    category["measurements"].empty? ? 1 : category["measurements"].count
                  end
                end
              end
            end
          end
          expect(BaselineMeasurement.count).to eq(measurement_count)
        end

        it "imports the data correctly", schema: :v2 do
          expected = expected_baseline_measurement_data
          imported = import_and_sort(BaselineMeasurement)
          expect(imported).to eq(expected)
        end
      end
    end
  end


  private

  def expected_result_group_data
    @result_groups.map do |record|
      {
        nct_id: nct_id,
        ctgov_group_code: record["id"],
        result_type: "Baseline",
        title: record["title"],
        description: record["description"]
      }
    end
  end

  def import_and_sort(model)
    model.all.map { |x| x.attributes.except("id").symbolize_keys }
  end

def expected_baseline_measurement_data
    results = []
    @measures.each do |measure|
      base_result = {
        nct_id: nct_id,
        result_group_id: nil,
        ctgov_group_code: nil,
        classification: nil,
        category: nil,
        title: measure["title"],
        description: measure["description"],
        units: measure["unitOfMeasure"],
        population_description: measure["populationDescription"],
        param_type: measure["paramType"],
        param_value: nil,
        param_value_num: nil,
        dispersion_type: measure["dispersionType"],
        dispersion_value: nil,
        dispersion_value_num: nil,
        dispersion_lower_limit: nil,
        dispersion_upper_limit: nil,
        explanation_of_na: nil,
        calculate_percentage: measure["calculatePct"].nil? ? nil : (measure["calculatePct"] == false ? "No" : "Yes"),
        number_analyzed: nil,
        number_analyzed_units: BaselineMeasurement::PARTICIPANTS
      }

      if measure["classes"].nil? || measure["classes"].empty?
        # If no classes, still add a base measure entry
        results << base_result
      else
        measure["classes"].each do |measure_class|
          class_result = base_result.merge(classification: measure_class["title"])

          if measure_class["categories"].nil? || measure_class["categories"].empty?
            # If no categories, still add a class-level entry
            results << class_result
          else
            measure_class["categories"].each do |category|
              category_result = class_result.merge(category: category["title"])

              if category["measurements"].nil? || category["measurements"].empty?
                # If no measurements, still add a category-level entry
                results << category_result
              else
                category["measurements"].each do |measurement|

                  measurement_result = category_result.dup

                  group_id = measurement["groupId"]
                  denom_unit = measure["denomUnitsSelected"] || BaselineMeasurement::PARTICIPANTS
                  denoms = measure_class["denoms"] || measure["denoms"]
                  
                  denom_unit_value = find_denom_value(denoms, group_id, denom_unit)
                  
                  measurement_result.merge!({
                    result_group_id: ResultGroup.where(ctgov_group_code: group_id).pluck(:id).first,
                    ctgov_group_code: group_id,
                    param_value: measurement["value"],
                    param_value_num: begin BigDecimal(measurement["value"]) rescue nil end,
                    dispersion_value: measurement["spread"],
                    dispersion_value_num: begin BigDecimal(measurement["spread"]) rescue nil end,
                    dispersion_lower_limit: begin BigDecimal(measurement["lowerLimit"]) rescue nil end,
                    dispersion_upper_limit: begin BigDecimal(measurement["upperLimit"]) rescue nil end,
                    explanation_of_na: measurement["comment"],
                    number_analyzed: denom_unit_value.nil? ? nil : denom_unit_value.to_i,
                    number_analyzed_units: denom_unit
                  })
                  results << measurement_result
                end
              end
            end
          end
        end
      end
    end
    results
  end

  def find_denom_value(denoms, group_id, denom_unit)
    denoms ||= @denoms

    denom = denoms.find { |d| d["units"] == denom_unit }
    group = denom&.fetch("counts", [])&.find { |count| count["groupId"] == group_id }
    group["value"]
  end
end
