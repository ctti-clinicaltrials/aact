require 'rails_helper'

RSpec.describe Admin::DataDefinition, type: :model do

  it "populates for each table and saves correct row counts" do

    #load one study to be able to check enumerations and row counts
    nct_id='NCT02028676'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    CalculatedValue.new.create_from(study).save!

    data=Roo::Spreadsheet.open('spec/support/shared_examples/aact_data_definitions.xlsx')
    Util::Updater.new.refresh_data_definitions(data)
    expect(Admin::DataDefinition.count).to eq(335)
    expect(Admin::DataDefinition.where('table_name=? and column_name=?','studies','nct_id').first.row_count).to eq(1)
    Util::Updater.single_study_tables.each{|tab|
      expect(Admin::DataDefinition.where('table_name=? and column_name=?',tab,'id').first.row_count).to eq(1) if tab != 'studies'
    }
    # random sample to verify row counts got set correctly for one-to-many related tables
    expect(Admin::DataDefinition.where('table_name=? and column_name=?','outcome_measurements','id').first.row_count).to eq(study.outcome_measurements.size)
    expect(Admin::DataDefinition.where('table_name=? and column_name=?','browse_conditions','id').first.row_count).to eq(study.browse_conditions.size)
    expect(Admin::DataDefinition.where('table_name=? and column_name=?','facilities','id').first.row_count).to eq(study.facilities.size)
    expect(Admin::DataDefinition.where('table_name=? and column_name=?','outcome_counts','id').first.row_count).to eq(study.outcome_counts.size)
    expect(Admin::DataDefinition.where('table_name=? and column_name=?','baseline_counts','id').first.row_count).to eq(study.baseline_counts.size)

    # random sample to verify enumerations got set
    enum=Admin::DataDefinition.where('table_name=? and column_name=?','eligibilities','gender').first.enumerations
    expect(enum['All']).to eq(['1', '100.0%'])
    enum=Admin::DataDefinition.where('table_name=? and column_name=?','sponsors','agency_class').first.enumerations
    expect(enum['Other']).to eq(['2', '50.0%'])
    expect(enum['Industry']).to eq(['2', '50.0%'])
    enum=Admin::DataDefinition.where('table_name=? and column_name=?','studies','phase').first.enumerations
    expect(enum['Phase 4']).to eq(['1', '100.0%'])
  end

end
