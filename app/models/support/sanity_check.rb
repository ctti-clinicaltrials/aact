module Support
  class SanityCheck < Support::SupportBase

    def save_row_counts
      Util::Updater.loadable_tables.each do |table_name|
        table_name = 'references' if table_name == 'study_references'

        count = table_name.singularize.camelize.constantize.count

        Support::SanityCheck.create(
          table_name: table_name,
          row_count: count,
          check_type: 'row count',
          most_current: true
        )
      end
    end

    # find all the studies which are orphaned
    def check_for_orphans
      parent_children_relationships.each do |r|
        parent = r.first
        child = r.last
        query = self.orphan_check_sql(parent,child)
        counter = 0
        ActiveRecord::Base.connection.execute(query).each do |orphan|
          counter += 1

          Support::SanityCheck.create(
            nct_id: orphan['nct_id'],
            table_name: child,
            check_type: 'orphan',
            description: "Orphaned from #{parent}",
            most_current: true
          )

          return if cntr > 100  # if a widespread problem, we just need to see some examples
        end
      end
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

    # find all the duplicated entries in tables which should have only
    # one row per study
    def check_for_duplicates
      Util::Updater.single_study_tables.each do |table_name|
        results = ActiveRecord::Base.connection.execute("
           SELECT nct_id, count(*)
             FROM #{table_name}
             GROUP BY nct_id
             HAVING COUNT(*) > 1")

        results.values.each do |row|
          Support::SanityCheck.create(
            table_name: "#{table_name} duplicate",
            nct_id: row.first,
            row_count: row.last,
            check_type: 'duplicate',
            most_current: true
          )
        end
      end
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
              Support::SanityCheck.new({
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

    # return all sanity checks not of type 'row count'
    def self.current_issues
      Support::SanityCheck.where(most_current: true).where.not(check_type: 'row count').map do |issue|
        "#{issue.check_type}: #{issue.table_name} #{ issue.row_count} #{issue.column_name} #{issue.description}"
      end
    end

    # not currently using for anything might stop doing this at some point
    def run
      # prepare the sanity checks table so that nothing is the most current
      Support::SanityCheck.update_all(most_current: false)

      save_row_counts
      check_for_orphans
      check_for_duplicates
    end
  end
end
