require 'active_support/all'
module Admin
  class DataDefinition < Admin::AdminBase
    self.table_name='data_definitions'

    def self.populate(data=Util::FileManager.new.default_data_definitions)
      begin
        self.destroy_all
        self.populate_from_file(data)
        self.populate_row_counts
        Admin::Enumeration.populate
      rescue => error
        # no guarantee the AACT Admin db exists
        puts "#{Time.zone.now}: Unable to populate data definitions.  #{error.message}"
      end
    end

    def self.populate_from_file(data=Util::FileManager.new.default_data_definitions)
      begin
        header = data.first
        dataOut = []
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
      rescue => error
        # no guarantee the AACT Admin db exists
        puts "#{Time.zone.now}: Unable to populate data definitions.  #{error.message}"
      end
    end

    def self.populate_row_counts
      # save count for each table where the primary key is id
      begin
        rows=where("column_name='id'")
        populate_from_file if rows.size==0
        rows.each{|row|
          begin
            results=ActiveRecord::Base.connection.execute("select count(*) from #{row.table_name}")
            row.row_count=results.getvalue(0,0) if results.ntuples == 1
            row.save
          rescue
            puts "#{Time.zone.now}: Could not get row count for #{row.table_name}"
          end
        }
        # Studies table is an exception - primary key is nct_id
        row=where("table_name='studies' and column_name='nct_id'").first
        return if row.nil?
        results=ActiveRecord::Base.connection.execute("select count(*) from #{row.table_name}")
        row.row_count=results.getvalue(0,0) if results.ntuples == 1
        row.save
      end
    rescue => error
      # no guarantee the AACT Admin db exists
      puts "#{Time.zone.now}: Unable to populate data definitions.  #{error.message}"
    end
  end
end
