class DataMappingService
  def initialize(mapping)
    @mapping = mapping
  end

  def data_mapping
    # process_mapping(@mapping)
    all_mappings = process_json(@mapping)

    deduplicated_mappings = all_mappings.uniq { |entry| [ entry[:table_name], entry[:field_name], entry[:api_path] ] }

    # Bulk upsert operation for efficiency
    CtgovApi::Mapping.upsert_all(deduplicated_mappings, unique_by: [ :table_name, :field_name, :api_path ])
  end


  def process_json(mappings, parent_root = nil)
    all_mappings = [] # aka records in the mapping table

    mappings.each do |mapping|
      root = build_root(parent_root, mapping)
      # all_mappings += extract_mapping_entries(map, root) # switch to concat for memory efficiency

      # check for mapping without columns
      mapping["columns"].each do |column|
        full_path_array = build_full_path(root, column["value"])
        api_path = full_path_array.join(".")

        all_mappings << {
          table_name: mapping["table"],
          field_name: column["name"],
          api_path: api_path,
          ctgov_api_metadata_id: fetch_metadata_id(api_path),
          active: true,
          created_at: Time.now,
          updated_at: Time.now
        }
      end

      if mapping["children"]
        all_mappings += process_json(mapping["children"], root)
      end
    end
    all_mappings
  end

  private

  def fetch_metadata_id(api_path)
    metadata = CtgovApi::Metadata.find_by(path: api_path)
    metadata&.id
  end

  def build_root(parent_root, mapping)
    root = parent_root ? parent_root.dup : []
    root += mapping["root"] if mapping["root"]
    # TODO: double check auto adding of flatten
    root += mapping["flatten"] if mapping["flatten"]
    root
  end

  def build_full_path(root, value)
    full_path = root ? root.dup : []

    if value.is_a?(Array)
      # Handle $parent references
      value.each do |v|
        if v == "$parent"
          full_path.pop # Remove the last element (going "up" one level)
        else
          full_path << v
        end
      end
    else
      full_path << value
    end

    full_path
  end
end
