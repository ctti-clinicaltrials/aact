class SanityCheck < ActiveRecord::Base

  def self.save_row_counts
    ClinicalTrials::Updater.loadable_tables.each{|table_name|
      table_name='references' if table_name=='study_references'
      cnt=table_name.singularize.camelize.constantize.count
      new({:table_name=>table_name,:row_count=>cnt}).save!
    }
  end

  def self.check_for_orphans
    parent_children_relationships.each{|r|
      parent = r.first
      child = r.last
      query=self.orphan_check_sql(parent,child)
      cntr=0
      ActiveRecord::Base.connection.execute(query).each{|orphan|
        cntr=cntr+1
        new({:nct_id=>orphan['nct_id'],:table_name=>child,:description=>"Orphaned from #{parent}"}).save
        return if cntr > 100  # if a widespread problem, we just need to see some examples
      }
    }
  end

  def self.orphan_check_sql(parent,child)
    "SELECT  distinct l.nct_id
       FROM    #{child} l
     LEFT JOIN #{parent} r
         ON  r.nct_id = l.nct_id
      WHERE  r.nct_id IS NULL "
  end

  def self.parent_children_relationships
    [
      ['studies','outcomes'],
      ['studies','reported_events'],
      ['outcomes','outcome_measures'],
      ['outcomes','outcome_analyses'],
      ['outcomes','outcome_groups'],
      ['outcome_measures','outcome_measurements'],
      ['outcome_analyses','outcome_analysis_groups'],
    ]
  end

  def self.check_for_duplicates
    ClinicalTrials::Updater.single_study_tables.each{|table_name|
      results=ActiveRecord::Base.connection.execute("
         SELECT nct_id, count(*)
           FROM #{table_name}
           GROUP BY nct_id
           HAVING COUNT(*) > 1")
      results.values.each{|row|
        new({:table_name=>"#{table_name} duplicate",:nct_id=>row.first,:row_count=>row.last,:description=>'duplicate'}).save!
      }
    }
  end

  def self.run
    self.save_row_counts
    self.check_for_orphans
    self.check_for_duplicates
  end

  def generate_report
    ClinicalTrials::Updater.loadable_tables.inject({}) do |hash, table_name|
      hash[table_name] = {
        row_count: @connection.execute("select count(*) from #{table_name}").values.flatten.first.to_i,
        column_stats: generate_column_width_stats(table_name)
      }
      hash
    end.to_json
  end

  def generate_column_width_stats(table_name)
    blacklist = %w(
        schema_migrations
        load_events
        sanity_checks
        statistics
        study_xml_records
        use_cases
        use_case_attachments
      )
    return if blacklist.include?(table_name)

    column_names = @connection.execute("select column_name from information_schema.columns where table_name = '#{table_name}'")
                              .values.flatten

    column_counts = column_names.inject({}) do |column_hash, column|
      column_hash[column] = {}
      %w(max min avg).each do |operation|
        column_hash[column]["#{operation}_length"] = @connection.execute("select #{operation}(length(#{column}::text)) from \"#{table_name}\"")
                                                    .values.flatten.first.to_i
      end
      column_hash[column][:frequent_values] = @connection.execute("select left(#{column}::text, 30) from #{table_name} group by #{column} limit 10").values.flatten

      column_hash
    end

  end
end
