# snapshots daily
Dir["/app/public/static/static_db_copies/daily/*.zip"].each do |full|
  record = FileRecord.create(
    filename: File.basename(full),
    file_size: File.size(full),
    file_type: 'snapshot'
  )
  record.file.attach(io: File.open(full), filename: "#{record.filename}")
  record.update(url: record.file.service.send(:object_for, record.file.key).public_url)
end

# snapshots monthly
Dir["/app/public/static/static_db_copies/monthly/*.zip"].each do |full|
  record = FileRecord.create(
    filename: File.basename(full),
    file_size: File.size(full),
    file_type: 'snapshot'
  )
  record.file.attach(io: File.open(full), filename: "#{record.filename}")
  record.update(url: record.file.service.send(:object_for, record.file.key).public_url)
end

# update created_at
FileRecord.where(file_type: 'snapshot').each do |file|
  file.update(created_at: DateTime.parse(file.filename) + 5.hours)
end

# pipefiles daily
Dir["/app/public/static/exported_files/daily/*.zip"].each do |full|
  record = FileRecord.create(
    filename: File.basename(full),
    file_size: File.size(full),
    file_type: 'pipefiles'
  )
  record.file.attach(io: File.open(full), filename: "#{record.filename}")
  record.update(url: record.file.service.send(:object_for, record.file.key).public_url)
end

# pipefiles monthly
Dir["/app/public/static/exported_files/monthly/*.zip"].each do |full|
  record = FileRecord.create(
    filename: File.basename(full),
    file_size: File.size(full),
    file_type: 'pipefiles'
  )
  record.file.attach(io: File.open(full), filename: "#{record.filename}")
  record.update(url: record.file.service.send(:object_for, record.file.key).public_url)
end

# update created_at
FileRecord.where(file_type: 'pipefiles').each do |file|
  file.update(created_at: DateTime.parse(file.filename) + 5.hours)
end

# covid searches
Dir["/app/public/static/exported_files/covid-19/*.tsv"].each do |full|
  record = FileRecord.create(
    filename: File.basename(full),
    file_size: File.size(full),
    file_type: 'covid-19'
  )
  record.file.attach(io: File.open(full), filename: "#{record.filename}")
  record.update(url: record.file.service.send(:object_for, record.file.key).public_url)
end

FileRecord.where(file_type: 'covid-19').each do |file|
  file.update(created_at: DateTime.parse(file.filename) + 5.hours)
end
