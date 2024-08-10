class MeshHeading < ActiveRecord::Base

  validates :qualifier, presence: true
  validates :heading, presence: true
  validates :subcategory, presence: true

  def self.populate_from_file(file_name=Util::FileManager.new.default_mesh_headings)
    qualifier = ""
    heading = ""
    headings = []

    begin

      File.open(file_name).each_line do |line|
        if is_heading(line.split(" ").first)
          qualifier = line.split(" ").first
          heading = line[4..line.size]
        else
          record = new(qualifier: qualifier.strip, heading: heading.strip, subcategory: line.strip)
          headings << record if line.size > 1 && record.valid?
        end
      end

      silence_active_record do
        # use activerecord-import for efficient batch insert
        result = import(headings, on_duplicate_key_ignore: true)
        handle_import_results(result)
      end
      
    rescue Errno::ENOENT => e
      puts "File Not Found: #{e.message}".red
    rescue ActiveRecord::RecordInvalid => e
      puts "Validation error: #{e.message}".red
    rescue StandardError => e
      puts "An error occurred: #{e.message}".red
    end
  end
  

  private

  def self.is_heading(str)
    return false if str.nil?
    return false if str.size != 3
    suffix = str[1..2]
    return false if suffix.to_i.to_s.rjust(2,'0') != suffix  #last 2 chars need to be an integer
    true
  end

  def self.handle_import_results(result)
    puts "Successfully imported: #{result.ids.size} records".green
    
    if result.failed_instances.any?
        puts "Failed to import #{result.failed_instances.size} records".red
        result.failed_instances.each do |record|
          puts "#{record.inspect} Errors: #{record.errors.full_messages.join(', ')}"
        end
      end
  end
end
