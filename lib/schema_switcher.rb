module SchemaSwitcher
  def with_search_path(schema)
    original_search_path = ActiveRecord::Base.connection.schema_search_path
    ActiveRecord::Base.connection.schema_search_path = schema
    yield
  ensure
    ActiveRecord::Base.connection.schema_search_path = original_search_path
  end

  def with_v2_schema
    with_search_path('ctgov_v2, support, public') do
      yield
    end
  end
end