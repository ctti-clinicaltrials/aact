module CtgovApi
  class Mapping < ApplicationRecord
    self.table_name = "support.ctgov_mappings"

    belongs_to :ctgov_metadata,
      class_name: "CtgovApi::Metadata",
      foreign_key: "ctgov_metadata_id",
      optional: true

    validates :table_name, :field_name, :api_path, presence: true
  end
end
