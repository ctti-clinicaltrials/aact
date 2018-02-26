require 'active_support/all'
module Admin
  class HealthCheckEnumeration < Admin::AdminBase

    def self.create_from(hash)
      Admin::HealthCheckEnumeration.new(
        {:table_name     => hash[:table_name],
         :column_name    => hash[:column_name],
         :column_value   => hash[:column_value],
         :value_count    => hash[:value_count],
         :value_percent  => hash[:value_percent],
        }
      ).save!
    end

  end
end
