module ModelDataHelper
  include JsonHelper

  NCT_ID = "NCT001"

  def setup_test_data_for(model, path = models_import_path)
    content = load_json(model, path)
    record = StudyJsonRecord.new(nct_id: NCT_ID, version: "2", content: content)
    StudyJsonRecord::Worker.new.process(1, [record])
  end


  # TODO: improve for referential data
  def imported_data_for(model)
    model.where(nct_id: NCT_ID).map { |r| r.attributes.except("id") }
  end

  # currently not being used
  def imported_study_data_for(nct_id)
    study_data = { nct_id: nct_id, models: {} }
    StudyRelationship.loadable_tables.each do |table|
      model = table.classify.constantize
      records = imported_data_for(model)
      study_data[:models][model_class.name] = records
    end
    study_data
  end

  def expected_data_for(model, path = models_expected_path)
    json = load_json(model, path)
    json[model.name]
  end


  def compare_imported_with_expected_for(model)
    setup_test_data_for(model)
    imported = imported_data_for(model)
    expected = expected_data_for(model)
    expect(imported).to match_array(expected)
  end
end