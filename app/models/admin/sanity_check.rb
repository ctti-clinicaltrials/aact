module Admin
  class SanityCheck < Admin::AdminBase

    def save_row_counts
      Admin::AdminBase.connection.execute('UPDATE sanity_checks SET most_current=false')
      Util::Updater.loadable_tables.each{|table_name|
        table_name='references' if table_name=='study_references'
        cnt=table_name.singularize.camelize.constantize.count
        Admin::SanityCheck.new({
          :table_name=>table_name,
          :row_count=>cnt,
          :check_type=>'row count',
          :most_current=>true}).save!
      }
    end

    def check_for_orphans
      parent_children_relationships.each{|r|
        parent = r.first
        child = r.last
        query=self.orphan_check_sql(parent,child)
        cntr=0
        ActiveRecord::Base.connection.execute(query).each{|orphan|
          cntr=cntr+1
          Admin::SanityCheck.new({
            :nct_id=>orphan['nct_id'],
            :table_name=>child,
            :check_type=>'orphan',
            :description=>"Orphaned from #{parent}",
            :most_current=>true}).save
          return if cntr > 100  # if a widespread problem, we just need to see some examples
        }
      }
    end

    def orphan_check_sql(parent,child)
      "SELECT  distinct l.nct_id
         FROM    #{child} l
       LEFT JOIN #{parent} r
           ON  r.nct_id = l.nct_id
        WHERE  r.nct_id IS NULL "
    end

    def parent_children_relationships
      [
        ['studies','outcomes'],
        ['studies','reported_events'],
        ['outcomes','outcome_analyses'],
        ['outcomes','outcome_measurements'],
        ['outcome_analyses','outcome_analysis_groups'],
      ]
    end

    def check_for_duplicates
      Util::Updater.single_study_tables.each{|table_name|
        results=ActiveRecord::Base.connection.execute("
           SELECT nct_id, count(*)
             FROM #{table_name}
             GROUP BY nct_id
             HAVING COUNT(*) > 1")
        results.values.each{|row|
          Admin::SanityCheck.new({
            :table_name=>"#{table_name} duplicate",
            :nct_id=>row.first,
            :row_count=>row.last,
            :check_type=>'duplicate',
            :most_current=>true}).save!
        }
      }
    end

    def check_enumerations
      Admin::Enumeration.new.enums.each{|array|
        # each enumeration - check most recent % to last % & raise alert if it has changed > 10%
        table_name=array.first
        column_name=array.last

        Admin::Enumeration.get_values_for(table_name,column_name).each{|array|
          hash=Admin::Enumeration.get_last_two_for(table_name,column_name,array.first)
          if hash.size == 2
            last=hash[:last].value_percent
            next_last=hash[:next_last].value_percent
            diff=last - next_last
            if (diff.abs > 10)
              Admin::SanityCheck.new({
                :table_name=>"#{table_name}",
                :column_name=>"#{column_name}",
                :check_type=>"enumeration",
                :description=>"enumeration changed by more than 10%: #{next_last.round(2)}% -> #{last.round(2)}%",
                :most_current=>true}).save!
            end
          end
        }
      }
    end

    def self.current_issues
      col=[]
      Admin::SanityCheck.where('most_current=? and check_type != ?',true,'row count').each{|issue|
        col << "#{issue.check_type}: #{issue.table_name} #{ issue.row_count} #{issue.column_name} #{issue.description}"
      }
      return col
    end

    def run(event_type=nil)
      save_row_counts
      check_for_orphans
      check_for_duplicates
    end

    def generate_report
      Util::Updater.loadable_tables.inject({}) do |hash, table_name|
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
end
