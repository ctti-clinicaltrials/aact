require "rails_helper"
  
RSpec.describe IdInformation, type: :model do
  describe "Mapping" do
    let(:expected) { expected_data_for(described_class) }
    let(:imported) { imported_data_for(described_class) }

    before(:each) do
      # can't be moved to :all until rails_helper is updated
      setup_json_sample(described_class)
    end

    # TODO: work on example description
    it "creates an instance of #{described_class.name}" do
      puts "expected", expected
      puts "imported", imported
      expect(imported).to match_array(expected)
    end
  end
end