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
    JSON.parse(read_attribute(:report))
  end

  def generate_report
    @table_names.inject({}) do |hash, table_name|
      hash[table_name] = {
        row_count: @connection.execute("select count(*) from #{table_name}").values.flatten.first.to_i,
        column_stats: generate_column_width_stats(table_name)
      }
      hash
    end.to_json
  end

  def generate_column_width_stats(table_name)
    blacklist = %w(
        search_results
        derived_values
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
