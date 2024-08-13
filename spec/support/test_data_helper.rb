module TestDataHelper
  include JsonHelper

  def setup_study_json_record(nct_id)
    content = load_study_json(nct_id)
    record = StudyJsonRecord.new(nct_id: nct_id, version: "2", content: content)
    StudyJsonRecord::Worker.new.process(1, [record])
  end


  def setup_json_sample(model, nct_id = "NCT001")
    # byebug
    content = load_json(model)
    record = StudyJsonRecord.new(nct_id: nct_id, version: "2", content: content)
    StudyJsonRecord::Worker.new.process(1, [record])
  end


  def imported_data_for(model, nct_id = "NCT001")
    # byebug
    model.where(nct_id: nct_id).map{ |r| r.attributes.except("id") }
  end



  # define custom matcher instead of excluding keys in before extraction and comparison
  def compare_imported_with_expected(model_class, nct_id)
    keys_to_exclude = ["id", "intervention_id", "facility_id"]

    imported = model_class.where(nct_id: nct_id).map do |record|
      record.attributes.except("id", "intervention_id", "facility_id")
    end


    expected = load_expected_data_for(nct_id, model_class)

    # Compare the results
    expect(imported).to match_array(expected)
  end
end