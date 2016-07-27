namespace :simple_sanity_check do
  task run: :environment do
    connection = ActiveRecord::Base.connection
    table_names = TableExporter.new.send(:get_table_names, all: true)
    file_path = "#{Rails.root}/tmp/sanity_check.txt"

    column_max_lengths = table_names.inject({}) do |table_hash, table_name|
      blacklist = %w(
        search_results
        calculated_values
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

    counts = table_names.map do |table_name|
      {
        table_name: table_name,
        count: connection.execute("select count(*) from #{table_name}").values.flatten.first,
        column_max_lengths: column_max_lengths[table_name]
      }
    end

    File.open(file_path, 'w') do |file|
      counts.sort_by {|count| count[:count].to_i}.reverse.each do |count|
        file.write("#{count[:table_name]}: #{count[:count]} records.\n Max column lengths for #{count[:table_name]} #{count[:column_max_lengths]}\n\n\n")
      end
    end


    s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
    obj = s3.bucket(ENV['S3_BUCKET_NAME']).object("sanity_checks/#{Date.today}-sanity-check.txt")
    obj.upload_file(file_path)
  end
end
