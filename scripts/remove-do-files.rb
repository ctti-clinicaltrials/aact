s3 = Aws::S3::Client.new(endpoint: 'https://nyc3.digitaloceanspaces.com')
missing = []
s3.list_objects(bucket: 'ctti-aact').each do |response|
  response.contents.each do |object|
    blob = ActiveStorage::Blob.find_by(key: object.key)
    next if blob
    puts "missing #{object.key}"
    missing << object
  end
end

res = s3.delete_objects(
  bucket: 'ctti-aact',
  delete: {
    objects: missing.map{|k| { key: k.key }},
    quiet: false
  }
)