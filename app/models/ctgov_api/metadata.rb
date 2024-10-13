module CtgovApi
  class Metadata < ApplicationRecord
    self.table_name = "support.ctgov_metadata"

    # TODO: Add active flag - to handle changes coming from the API

    has_many :mappings,
      class_name: "CtgovApi::Mapping",
      foreign_key: "ctgov_api_metadata_id"

    validates :name, :data_type, :path, :version, presence: true
  end
end
