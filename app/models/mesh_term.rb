class MeshTerm < ActiveRecord::Base
  BATCH_SIZE = 10_000

  validates :qualifier, presence: true
  validates :tree_number, presence: true
  validates :mesh_term, presence: true
  validates :downcase_mesh_term, presence: true

  def self.populate_from_file(file_name = Util::FileManager.new.default_mesh_terms)
    begin
      # Clear all existing records
      MeshTerm.delete_all
      
      batch = []
      File.open(file_name).each_line.with_index do |line, index|
        line_array = line.strip.split(' ')
        tree = line_array.first
        qualifier = tree.split('.').first
        term = line.split(/\t/).last.strip

        if qualifier.present?
          record = new(
            qualifier: qualifier,
            tree_number: tree,
            mesh_term: term,
            downcase_mesh_term: term.downcase
          )
          batch << record
        end

        if batch.size >= BATCH_SIZE
          import_batch(batch)
          batch.clear
        end
      end

      import_batch(batch) unless batch.empty?
      
    rescue Errno::ENOENT => e
      puts "File Not Found: #{e.message}".red
    rescue ActiveRecord::RecordInvalid => e
      puts "Validation error: #{e.message}".red
    rescue StandardError => e
      puts "An error occurred: #{e.message}".red
    end
  end

  # TODO: Review the implementation when mesh logic is finilized
  def self.ids_related_to(incoming_terms=[])
    ids=[]
    incoming_terms.each {|term|
      searchable_term="%#{term.downcase}%"
      terms=MeshTerm.where('downcase_mesh_term like ?',searchable_term).pluck("mesh_term").uniq
      terms.each{|term|
        t=term.downcase
        ids << BrowseCondition.where('downcase_mesh_term = ?',t).pluck(:nct_id).uniq
        ids << BrowseIntervention.where('downcase_mesh_term = ?',t).pluck(:nct_id).uniq
      }
    }
    ids.flatten.uniq
  end

  private

  def self.import_batch(batch)
    silence_active_record do
      result = MeshTerm.import(batch)
      handle_import_results(result)
    end
  end

  def self.handle_import_results(result)
    puts "Successfully imported: #{result.ids.size} records".green

    if result.failed_instances.any?
      puts "Failed to import #{result.failed_instances.size} records".red
      result.failed_instances.each do |record|
        puts "#{record.inspect} Errors: #{record.errors.full_messages.join(", ")}"
      end
    end
  end
end