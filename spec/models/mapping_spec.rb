require "rails_helper"

RSpec.describe "Mapping", type: :model do
  # would using data service be better here?
  tables = ["id_information", "condition"]

  tables.each do | table_name |
    model = table_name.classify.constantize # convert table to class

    describe "#{model} Model" do
      it "creates an instance of #{model}" do
        compare_imported_with_expected_for(model)
      end
    end
  end
end