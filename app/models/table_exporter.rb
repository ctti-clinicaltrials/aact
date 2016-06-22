class TableExporter
  ZIPFILE_NAME = "#{Rails.root}/tmp/export.csv"

  def run
    File.delete(ZIPFILE_NAME) if File.exist?(ZIPFILE_NAME)

    tempfile = Tempfile.new('table.csv')
    tempfile2 = Tempfile.new('table2.csv')

    Zip::File.open(ZIPFILE_NAME, Zip::File::CREATE) do |zipfile|
      [tempfile, tempfile2].each do |file|
        zipfile.add(file, file.path)
      end
    end

    Zip::File.open(ZIPFILE_NAME) do |zipfile|
      puts "Entries from reloaded zip: #{zipfile.entries.join(', ')}"
    end
  end
end
