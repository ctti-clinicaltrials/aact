require 'active_support/all'
module Admin
  class Project < Admin::AdminBase

    def self.schema_name_array
      all.map {|x| x.schema_name}.uniq
    end

  end
end
