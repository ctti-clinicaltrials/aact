class SanityCheck < ActiveRecord::Base
  def initialize
    super
    @connection = ActiveRecord::Base.connection
    @table_names = TableExporter.new.send(:get_table_names, all: true)
  end

  def self.run
    sanity_check = new
    sanity_check.report = sanity_check.generate_report
    sanity_check.save
  end

  def report
    JSON.parse(read_attribute(:report), object_class: OpenStruct)
  end

  def generate_report
    @table_names.inject({}) do |hash, table_name|
      hash[table_name] = {
        row_count: @connection.execute("select count(*) from #{table_name}").values.flatten.first.to_i,
        column_width_stats: generate_column_width_stats(table_name)
      }
      hash
    end.to_json
  end

  def generate_column_width_stats(table_name)
    column_max_lengths = @table_names.inject({}) do |table_hash, table_name|
      blacklist = %w(
        search_results
        derived_values
      )

      next table_hash if blacklist.include?(table_name)

      @table_name = table_name

      if table_name == 'study_references'
        @table_name = 'references'
      end

      begin
        column_counts = @table_name.classify.constantize.column_names.inject({}) do |column_hash, column|
          column_hash[column] = connection.execute("select max(length(#{column}::text)) from \"#{table_name}\"").values.flatten.first
          column_hash
        end
      rescue NameError
        puts "skipping table that doesnt have model: #{@table_name}"
      end

      table_hash[table_name] = column_counts
      table_hash
    end
  end
end
