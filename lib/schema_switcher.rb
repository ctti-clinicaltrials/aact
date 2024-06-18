module SchemaSwitcher
  def with_search_path(schema)
    original_search_path = ActiveRecord::Base.connection.schema_search_path
    ActiveRecord::Base.connection.schema_search_path = schema
    StudyRelationship.study_models.each do |model|
      model.reset_column_information
    end
    yield
  ensure
    ActiveRecord::Base.connection.schema_search_path = original_search_path
    StudyRelationship.study_models.each do |model|
      model.reset_column_information
    end
  end

  def with_v2_schema
    with_search_path('ctgov_v2, support, public') do
      yield
    end
  end
end