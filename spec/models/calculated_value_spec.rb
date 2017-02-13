require 'rails_helper'

describe CalculatedValue do
  it "should not have actual_duration if completion date is 'anticipated'" do
    nct_id='NCT00482794'
    # this study's primary completion date is 'anticipated'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    CalculatedValue.refresh_table
    expect(study.completion_date_type).to eq('Anticipated')
    cv=study.calculated_value
    expect(cv.has_us_facility).to eq(true)
    expect(cv.has_single_facility).to eq(true)
    expect(cv.actual_duration).to eq(nil)
    expect(cv.months_to_report_results).to eq(nil)
    expect(cv.were_results_reported).to eq(false)
    expect(cv.registered_in_calendar_year).to eq(2007)
  end

  it "should not have actual_duration if completion date is 'anticipated'" do
    nct_id='NCT00023673'
    # this study's primary completion date is 'actual'
    #  actual duration:   7/01-1/09 = 7 years & 6 months (91 months)
    #  months to report:  1/09-2/14 = 5 years & 2 months (62 months)

    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.eligibility.gender).to eq('All')

    CalculatedValue.refresh_table
    expect(study.start_month_year).to eq('July 2001')
    expect(study.primary_completion_month_year).to eq('January 2009')
    expect(study.primary_completion_date_type).to eq('Actual')
    expect(study.first_received_results_date.strftime('%m/%d/%Y')).to eq('02/12/2014')
    cv=study.calculated_value
    expect(cv.were_results_reported).to eq(true)
    expect(cv.has_us_facility).to eq(true)
    expect(cv.has_single_facility).to eq(false)
    expect(cv.actual_duration).to eq(91)
    expect(cv.months_to_report_results).to eq(62)
  end

  it "should set has_us_facility to nil if no facilities provided" do
    nct_id='NCT02591810'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    CalculatedValue.refresh_table
    expect(study.calculated_value.has_us_facility).to eq(nil)
  end

  it "should set correct calculated values for a set of studies" do
    nct_id1='NCT00023673'
    nct_id2='NCT02028676'
    expect(CalculatedValue.count).to eq(0)

    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id1}.xml"))
    study1=Study.new({xml: xml, nct_id: nct_id1}).create

    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id2}.xml"))
    study2=Study.new({xml: xml, nct_id: nct_id2}).create

    CalculatedValue.refresh_table
    expect(CalculatedValue.count).to eq(2)

    expect(study1.start_month_year).to eq('July 2001')
    expect(study1.primary_completion_month_year).to eq('January 2009')
    expect(study1.primary_completion_date_type).to eq('Actual')
    expect(study1.first_received_results_date.strftime('%m/%d/%Y')).to eq('02/12/2014')

    cv=study1.calculated_value
    expect(cv.were_results_reported).to eq(true)
    expect(cv.has_us_facility).to eq(true)
    expect(cv.has_single_facility).to eq(false)
    expect(cv.actual_duration).to eq(91)
    expect(cv.months_to_report_results).to eq(62)

    cv=study2.calculated_value
    expect(study2.start_month_year).to eq('March 2007')
    expect(study2.primary_completion_month_year).to eq('March 2012')
    expect(study2.first_received_results_date.strftime('%m/%d/%Y')).to eq('01/15/2014')
    expect(cv.were_results_reported).to eq(true)
    expect(cv.has_us_facility).to eq(false)

    expect(cv.has_single_facility).to eq(false)
    expect(cv.actual_duration).to eq(60)
    expect(cv.months_to_report_results).to eq(22)
    expect(cv.number_of_sae_subjects).to eq(1458)
    expect(cv.number_of_nsae_subjects).to eq(1889)

  end

end
