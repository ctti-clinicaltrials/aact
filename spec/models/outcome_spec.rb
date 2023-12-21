require 'rails_helper'

describe Outcome do

  it "handles converting anticipated_posting_month_year" do
    nct_id='NCT01380080'  # anticipated_posting_month_year = 12/2020
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    o=study.outcomes.select{|x|x.title=='Proportion of Participants With Reportable Hospitalization by Week 48'}.first
    expect(o.anticipated_posting_month_year).to eq('12/2020')
    expect(o.anticipated_posting_date).to eq(Date.parse('31-12-2020'))

    nct_id='NCT01534533'  # anticipated_posting_month_year = 3333
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    o=study.outcomes.select{|x|x.title=='Dietary Intake of Energy During the Study Periods'}.first
    expect(o.anticipated_posting_month_year).to eq('12/3333')
    expect(o.anticipated_posting_date).to eq(Date.parse('31-12-3333'))

    nct_id='NCT01357915'  # anticipated_posting_month_year = 2025
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    o=study.outcomes.select{|x|x.title=='Number of Subjects With Neutralizing Response Against Anti-CMV Antibodies'}.first
    expect(o.anticipated_posting_month_year).to eq('2025')
    expect(o.anticipated_posting_date).to eq(nil)  # invalid date
  end

  it "should have expected info" do
    # and saves units_analyzed"
    nct_id='NCT00277524'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    o=study.outcomes.select{|x|x.title=='ICD/CRT-D Device Baseline Programming Frequencies'}.first
    expect(o.units_analyzed).to eq('Participants')
  end
end
