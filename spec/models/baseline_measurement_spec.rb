require "rails_helper"

describe "BaselineMeasurement and Baseline ResultGroup" do
  NCT_ID = "NCT000001"

  json_files = [
    "baseline_measurements_1.json",
    "baseline_measurements_2.json",
    "baseline_measurements_3.json",
    "baseline_measurements_4.json",
    "baseline_measurements_5.json"
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

        StudyJsonRecord.create(nct_id: NCT_ID, version: "2", content: content)
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
            measure["classes"].sum do |measure_class|
              measure_class["categories"].sum do |category|
                category["measurements"].count
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


  # TODO: Add test for this method
  def expected_baseline_measurement_data
    @measures.flat_map do |measure|
      measure["classes"].flat_map do |measure_class|
        measure_class["categories"].flat_map do |category|
          category["measurements"].map do |measurement|

            group_id = measurement["groupId"]
            denom_units = measure["denomUnitsSelected"] || BaselineMeasurement::PARTICIPANTS
            denoms = measure_class["denoms"] || measure["denoms"]

            if denoms.nil?
              denom = @denoms.find { |denom| denom["units"] == denom_units }
              group = denom["counts"].find { |count| count["groupId"] == group_id }
              denom_value = group["value"]
            else
              denoms.find do |denom|
                if denom["units"] == denom_units
                  denom["counts"].find do |count|
                    denom_value = count["value"] if count["groupId"] == measurement["groupId"]
                  end
                end
              end
            end
            
            {
              nct_id: NCT_ID,
              result_group_id: ResultGroup.where(ctgov_group_code: group_id).pluck(:id).first,
              ctgov_group_code: group_id,

              classification: measure_class["title"],
              category: category["title"],

              title: measure["title"],
              description: measure["description"],
              units: measure["unitOfMeasure"],
              population_description: measure["populationDescription"],

              param_type: measure["paramType"],
              param_value: measurement["value"],
              param_value_num: begin BigDecimal(measurement["value"]) rescue nil end,
            
              dispersion_type: measure["dispersionType"],
              dispersion_value: measurement["spread"],
              dispersion_value_num: begin BigDecimal(measurement["spread"]) rescue nil end,
              dispersion_lower_limit: begin BigDecimal(measurement["lowerLimit"]) rescue nil end,
              dispersion_upper_limit: begin BigDecimal(measurement["upperLimit"]) rescue nil end,

              explanation_of_na: measurement["comment"],

              calculate_percentage: measure["calculatePct"].nil? ? nil : (measure["calculatePct"] == false ? "No" : "Yes"),
              number_analyzed: denom_value.nil? ? nil : denom_value.to_i, # to avoid possible nil to 0 conversion
              number_analyzed_units: denom_units,
            }
          end
        end
      end
    end
  end

  def expected_result_group_data
    @result_groups.map do |record|
      {
        nct_id: NCT_ID,
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
end
