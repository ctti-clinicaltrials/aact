require 'csv'
require 'active_support/all'
module Admin
  class DataDefinition < Admin::AdminBase

    def self.populate(data=Util::FileManager.default_data_definitions)
      self.destroy_all
      self.populate_from_file(data)
      self.populate_row_counts
      self.populate_enumerations
    end

    def self.populate_from_file(data=Util::FileManager.default_data_definitions)
      header = data.first
      dataOut = []
      puts "about to populate data definitions table..."
      (2..data.last_row).each do |i|
        row = Hash[[header, data.row(i)].transpose]
        if !row['table'].nil? and !row['column'].nil?
          new(:db_section=>row['db section'].try(:downcase),
              :table_name=>row['table'].try(:downcase),
              :column_name=>row['column'].try(:downcase),
              :data_type=>row['data type'].try(:downcase),
              :source=>row['source'].try(:downcase),
              :ctti_note=>row['CTTI note'],
              :nlm_link=>row['nlm doc'],
             ).save!
        end
      end
    end

    def self.populate_row_counts
      # save count for each table where the primary key is id
      rows=where("column_name='id'")
      populate_from_file if rows.size==0
      rows.each{|row|
        begin
          results=ActiveRecord::Base.connection.execute("select count(*) from #{row.table_name}")
          row.row_count=results.getvalue(0,0) if results.ntuples == 1
          row.save
        rescue
          puts ">>>>  could not get row count for #{row.table_name}"
        end
      }
      # Studies table is an exception - primary key is nct_id
      row=where("table_name='studies' and column_name='nct_id'").first
      return if row.nil?
      results=ActiveRecord::Base.connection.execute("select count(*) from #{row.table_name}")
      row.row_count=results.getvalue(0,0) if results.ntuples == 1
      row.save
    end

    def self.populate_enumerations
      dd_rows=where("column_name='id'").size
      populate_from_file if dd_rows==0
      Admin::HealthCheckEnumeration.enums.each{|array|
        begin
          table_name=array.first
          column_name=array.last
          full_count=ActiveRecord::Base.connection.execute("SELECT count(*) FROM #{table_name}")
          rows=full_count.getvalue(0,0).to_i if full_count.ntuples == 1

          results=ActiveRecord::Base.connection.execute("
                      SELECT DISTINCT #{array.last}, COUNT(*) AS cnt
                        FROM #{table_name}
                       GROUP BY #{column_name}
                       ORDER BY cnt ASC")

          entries=results.ntuples - 1
          # hash to be used to create a populate the enumeration column of the data def record
          hash={}
          # healthcheck hash to be used to create a health check record for the enumeration
          hc_hash={:table_name=>table_name,:column_name=>column_name}
          while entries >= 0 do
            val=results.getvalue(entries,0).to_s
            val='null' if val.size==0
            val='true' if val=='t'
            val='false' if val=='f'
            cnt=results.getvalue(entries,1)
            pct=(cnt.to_f/rows.to_f)*100
            display_count=cnt.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
            display_percent="#{pct.round(2)}%"
            hash[val]=[display_count,display_percent]
            hc_hash[:column_value]=val
            hc_hash[:value_count]=cnt.to_i
            hc_hash[:value_percent]=pct
            Admin::HealthCheckEnumeration.create_from(hc_hash) if hc_hash.size > 2
            entries=entries-1
          end
          row=where("table_name=? and column_name=?",table_name,column_name).first
          row.enumerations=hash.to_json
          row.save
        rescue => e
          puts ">>>>  could not determine enumerations for #{table_name}  #{column_name}"
          puts e.inspect
        end
      }
    end

  end
end
