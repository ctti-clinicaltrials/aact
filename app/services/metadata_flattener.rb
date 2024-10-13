class MetadataFlattener
  def initialize(metadata, version)
      @metadata = metadata
      @version = version || "v2"
  end

  def flatten
    flatten_json(@metadata)
  end

  private

  def flatten_json(node, parent_path = [])
    flattened_data = []

    # metadata returns an array of objects
    if node.is_a?(Array)
      node.each do |child|
        flattened_data += flatten_json(child, parent_path)
      end
    elsif node["children"] # Current node has children, so it's not a leaf node
      current_path = parent_path + [ node["name"] ]
      node["children"].each do |child|
        flattened_data += flatten_json(child, current_path)
      end
    else
      # should be a leaf node
      # TODO: insert all at once?
      api_field = CtgovApi::Metadata.create(
          name: node["name"],
          data_type: node["type"],
          piece: node["piece"],
          source_type: node["sourceType"],
          synonyms: node["synonyms"],
          label: node.dig("dedLink", "label"),
          url: node.dig("dedLink", "url"),
          section: parent_path[0],  # First part of the path is section
          module: parent_path[1],   # Second part is module
          path: (parent_path + [ node["name"] ]).join("."),
          version: @version
        )
      flattened_data << api_field
    end

    flattened_data
  end
end
