module TestDataHelper
  include JsonHelper


  def setup_json_sample(model, path = models_import_path, nct_id = "NCT001")
    content = load_json(model, path)
    record = StudyJsonRecord.new(nct_id: nct_id, version: "2", content: content)
    StudyJsonRecord::Worker.new.process(1, [record])
  end


  def imported_data_for(model, nct_id = "NCT001")
    model.where(nct_id: nct_id).map{ |r| r.attributes.except("id") }
  end

  def expected_data_for(model, path = models_expected_path)
    json = load_json(model, path)
    json[model.name]
  end


  def compare_imported_with_expected_for(model)
    setup_json_sample(model)
    imported = imported_data_for(model)
    expected = expected_data_for(model)
    expect(imported).to match_array(expected)
  end
end