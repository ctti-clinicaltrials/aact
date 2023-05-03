class Support::StudyStatisticsComparison < Support::SupportBase
  self.table_name = 'support.study_statistics_comparisons'

  def description
    if table
      "#{table}##{column}##{condition}"
    else
      "instances query:\n#{instances_query}\n\nunique_query:\n#{unique_query}"
    end
  end

  def get_database_counts
    con = ActiveRecord::Base.connection

    if instances_query
      instances = con.execute(instances_query).first['count']
      unique = con.execute(unique_query).first['count']
    else
      result = con.execute("SELECT COUNT(#{column}) AS val FROM #{table} #{condition}")
      result = result.first
      instances = result ? result['val'] : 0

      result = con.execute("SELECT COUNT(DISTINCT #{column}) AS val FROM #{table} #{condition}")
      result = result.first
      unique = result ? result['val'] : 0
    end

    return instances.to_i, unique.to_i
  end

  def get_ctgov_counts(source)
    node = source.dig(*ctgov_selector.split('|'))
    instances = node.dig("nInstances")
    unique = node.dig("nUniqueValues")

    return instances.to_i, unique.to_i
  end

  def compare(source)
    ctgov_instances, ctgov_uniq_values = get_ctgov_counts(source)
    db_instances, db_uniq_values = get_database_counts

    return {
      source: ctgov_selector,
      destination: description,
      source_instances: ctgov_instances,
      destination_instances: db_instances,
      source_unique_values: ctgov_uniq_values,
      destination_unique_values: db_uniq_values,
    }
  end
end
