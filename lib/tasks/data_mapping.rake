namespace :data_mapping do
  desc "Process mapping source file using DataMappingService"

  task process: :environment do
    puts "Processing mapping source file..."
    file = Rails.root.join("lib", "aact", "mapping.json")
    data = JSON.parse(File.read(file))

    service = DataMappingService.new(data)
    service.data_mapping
    puts "Mapping processed successfully!"
  end
end
