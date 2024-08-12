require "rails_helper"
  
RSpec.describe IdInformation, type: :model do
  describe "Mapping" do
    let(:nct_id) { "NCT06388018" }
    # let(:content) { load_study_json(nct_id) }
    let(:expected_data) { load_expected_data_for(nct_id, described_class) }

    # before do
    #   record = StudyJsonRecord.new(nct_id: nct_id, version: "2", content: content)
    #   StudyJsonRecord::Worker.new.process(1, [record])
    # end


    it "creates an instance of IdInformation" do
      # imported = IdInformation.where(nct_id: nct_id).map{ |r| r.attributes.except("id") }
      imported = imported_data_for(nct_id, described_class)
      puts "imported: ", imported
      puts "expected_data: ", expected_data
      # byebug
      expect(imported).to match_array(expected_data)
    end
  end
end