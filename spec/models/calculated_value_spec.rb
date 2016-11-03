require 'rails_helper'

describe CalculatedValue do
  it "should not have actual_duration if completion date is 'anticipated'" do
    nct_id='NCT00482794'
    # this study's primary completion date is 'anticipated'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.completion_date_type).to eq('Anticipated')
    cv=study.calculated_value
    expect(cv.has_us_facility).to eq(false)
    expect(cv.actual_duration).to eq(nil)
    expect(cv.months_to_report_results).to eq(nil)
  end

  it "should not have actual_duration if completion date is 'anticipated'" do
    nct_id='NCT00023673'
    # this study's primary completion date is 'actual'
    #  actual duration:   7/01-1/09 = 7 years & 6 months (91 months)
    #  months to report:  1/09-2/14 = 5 years & 2 months (62 months)
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.start_month_year).to eq('July 2001')
    expect(study.primary_completion_month_year).to eq('January 2009')
    expect(study.primary_completion_date_type).to eq('Actual')
    expect(study.first_received_results_date.strftime('%m/%d/%Y')).to eq('02/12/2014')
    cv=study.calculated_value
    expect(cv.has_us_facility).to eq(true)
    expect(cv.actual_duration).to eq(91)
    expect(cv.months_to_report_results).to eq(62)
  end

end
