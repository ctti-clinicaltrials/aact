namespace :metadata do
  desc "Flatten and print metadata information"

  task flatten: :environment do
    file_path = Rails.root.join("lib", "ctgov", "metadata.json")
    file_content = File.read(file_path)
    documents_metadata = JSON.parse(file_content)

    flattener = MetadataFlattener.new(documents_metadata, "2")
    flattened_metadata = flattener.flatten

    puts flattened_metadata
  end
end
