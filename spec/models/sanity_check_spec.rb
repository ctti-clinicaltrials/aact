require 'rails_helper'
describe SanityCheck do

  before do
    nct_id='NCT00023673'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    CalculatedValue.new.create_from(study).save!
    SanityCheck.save_row_counts
  end

  it 'should have one row for each study-related table' do
    expect(SanityCheck.count).to eq(40)
  end

  it 'should have row count 1 for each table that has 1-to-1 relationship with studies table' do
    ClinicalTrials::Updater.single_study_tables.each{|table_name|
       rows=SanityCheck.where('table_name=?',table_name)
       expect(rows.size).to eq(1)
       row=rows.first
       expect(row.row_count).to eq(1)
    }
  end

  it "correctly detects duplicates in tables with one-to-one relationship to study" do
    nct_id='NCT00023673'
    BriefSummary.new({:nct_id=>nct_id,:description=>"duplicate for #{nct_id}"}).save!
    SanityCheck.check_for_duplicates
    sc=SanityCheck.where('nct_id=? and table_name=?',nct_id,'brief_summaries duplicate')
    expect(sc.size).to eq(1)
  end

  it "correctly detects orphans" do
    nct_id='NCT01065844'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.outcomes.size).to eq(2)
    study.outcomes.each{|x|x.destroy}
    outcomes=Outcome.where('nct_id=?',nct_id)
    expect(outcomes.size).to eq(0)
    SanityCheck.check_for_orphans
    sc=SanityCheck.where('nct_id=?',nct_id)
    expect(sc.size).to eq(1)
    expect(sc.first.table_name).to eq('outcome_measurements')
    expect(sc.first.description).to eq('Orphaned from outcomes')
  end

end
