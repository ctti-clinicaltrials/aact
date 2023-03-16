class FileRecord < ApplicationRecord
  has_one_attached :file

  # post a new entry or update the already existing entry for the day
  def self.post(type, filename)
    raise "file #{filename} not found" unless File.exist?(filename) 

    file_size =  File.size(filename)

    dates = (Date.today.beginning_of_day..Date.today.end_of_day)
    record = FileRecord.find_by(file_type: type, created_at: dates)
    record = FileRecord.create(file_type: type) unless record

    record.file.attach(io: File.open(filename), filename: "#{File.basename(filename)}")

    record.update(
      url: record.file.service.send(:object_for, record.file.key).public_url,
      file_size: file_size,
      filename: "#{File.basename(filename)}",
    )
  end
end
