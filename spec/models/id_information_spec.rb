require "rails_helper"
  
RSpec.describe IdInformation, type: :model do
  describe "Mapping" do
    let(:expected) { expected_data_for(described_class) }
    let(:imported) { imported_data_for(described_class) }

    before(:each) { setup_test_data_for(described_class) }

    it "creates an instance of #{described_class.name}" do
      expect(imported).to match_array(expected)
    end
  end
end