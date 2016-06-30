module FastCount
  def fast_count_estimate(query)
    connection      = ActiveRecord::Base.connection
    table           = ActiveModel::Naming.plural(self)
    sanitized_query = connection.quote(query.to_sql)

    connection.execute("select count_estimate(#{sanitized_query})").values.flatten.first.to_i
  end
end
