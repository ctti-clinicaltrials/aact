namespace :simple_sanity_check do
  task run: :environment do
    connection = ActiveRecord::Base.connection
    table_names = TableExporter.new.send(:get_table_names, all: true)
    file_path = "#{Rails.root}/tmp/sanity_check.txt"

    counts = table_names.map do |table_name|
      {
        table_name: table_name,
        count: connection.execute("select count(*) from #{table_name}").values.flatten.first,
        table_width: connection.execute("select count(*) from information_schema.columns where table_name='#{table_name}'").values.flatten.first
      }
    end

    File.open(file_path, 'w') do |file|
      counts.sort_by {|count| count[:count].to_i}.reverse.each do |count|
        file.write("#{count[:table_name]}: #{count[:count]} records. #{count[:table_width]} columns in table.\n")
      end
    end


    s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
    obj = s3.bucket(ENV['S3_BUCKET_NAME']).object("#{Date.today}-sanity-check.txt")
    obj.upload_file(file_path)
  end
end
