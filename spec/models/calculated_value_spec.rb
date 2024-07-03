require "rails_helper"

RSpec.describe CalculatedValue, type: :model do
  let(:studies) { [{ nct_id: "NCT001" }, { nct_id: "NCT002" }] }

  before(:each) do
    # Create mock data for associated models
    Study.create!(
      nct_id: "NCT001",
      study_first_submitted_date: Date.today - 1.year,
      start_date: Date.today - 1.year,
      start_date_type: "ACTUAL",
      results_first_submitted_date: Date.today - 5.months,
      primary_completion_date: Date.today - 6.months,
      primary_completion_date_type: "ACTUAL",
    )
    Study.create!(
      nct_id: "NCT002",
      study_first_submitted_date: Date.today - 2.years,
      start_date: Date.today - 2.years,
      start_date_type: "ACTUAL",
      results_first_submitted_date: Date.today - 8.months,
      primary_completion_date: Date.today - 1.year,
      primary_completion_date_type: "ESTIMATED",
    )

    Outcome.create!(nct_id: "NCT001")
    Facility.create!(nct_id: "NCT001", country: "United States")
    Facility.create!(nct_id: "NCT001", country: "France")
    Facility.create!(nct_id: "NCT002", country: "Canada")
    Eligibility.create!(nct_id: "NCT001", minimum_age: "11 Months", maximum_age: "65 Years")
    DesignOutcome.create!(nct_id: "NCT001", outcome_type: "primary")
    DesignOutcome.create!(nct_id: "NCT001", outcome_type: "secondary")
    ReportedEvent.create!(nct_id: "NCT001", event_type: "serious", subjects_affected: 5)
    ReportedEvent.create!(nct_id: "NCT001", event_type: "serious", subjects_affected: 5)
    ReportedEvent.create!(nct_id: "NCT001", event_type: "other", subjects_affected: 3)
    ReportedEvent.create!(nct_id: "NCT001", event_type: "other", subjects_affected: 2)
    # Other necessary setup
  end


  describe ".perform_calculations" do
    before(:each) do
      CalculatedValue.populate_for(studies)
    end

    let(:calculations) { CalculatedValue.instance_variable_get(:@calculations) }

    it 'should correctly populate @calculations' do
      expect(calculations).to be_a(Hash)
      expect(calculations.keys).to include("NCT001", "NCT002")
    end

    it "processes were_results_reported correctly" do
      expect(calculations["NCT001"][:were_results_reported]).to be true
      expect(calculations["NCT002"][:were_results_reported]).to be false
    end

    it "processes facility info correctly" do
      expect(calculations["NCT001"][:number_of_facilities]).to eq(2)
      expect(calculations["NCT001"][:has_us_facility]).to be true
      expect(calculations["NCT001"][:has_single_facility]).to be false
      expect(calculations["NCT002"][:number_of_facilities]).to eq(1)
      expect(calculations["NCT002"][:has_us_facility]).to be false
      expect(calculations["NCT002"][:has_single_facility]).to be true
    end

    it "processes age info correctly" do
      expect(calculations["NCT001"][:minimum_age_num]).to eq(11)
      expect(calculations["NCT001"][:minimum_age_unit]).to eq("month")
      expect(calculations["NCT001"][:maximum_age_num]).to eq(65)
      expect(calculations["NCT001"][:maximum_age_unit]).to eq("year")
      expect(calculations["NCT002"][:minimum_age_num]).to eq(nil)
    end

    it "calculates dates correctly" do
      expect(calculations["NCT001"][:months_to_report_results]).to eq(1)
      expect(calculations["NCT001"][:actual_duration]).to eq(6)
      expect(calculations["NCT002"][:actual_duration]).to eq(nil)
      expect(calculations["NCT001"][:registered_in_calendar_year]).to eq(Date.today.year - 1)
    end

    it "processes outcome design counts correctly" do
      expect(calculations["NCT001"][:number_of_primary_outcomes_to_measure]).to eq(1)
      expect(calculations["NCT001"][:number_of_secondary_outcomes_to_measure]).to eq(1)
      expect(calculations["NCT002"][:number_of_primary_outcomes_to_measure]).to eq(nil)
    end

    it "processes event subject counts correctly" do
      expect(calculations["NCT001"][:number_of_sae_subjects]).to eq(10)
      expect(calculations["NCT001"][:number_of_nsae_subjects]).to eq(5)
      expect(calculations["NCT002"][:number_of_sae_subjects]).to eq(nil)
    end
  end
end
