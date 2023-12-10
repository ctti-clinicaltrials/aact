require 'rails_helper'

describe BaselineMeasurement do
  it "doesn't create baseline rows for studies that don't have <baseline> tag" do
    nct_id='NCT00513591'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.baseline_population).to eq('')
    expect(study.baseline_measurements).to eq([])
    expect(study.baseline_counts).to eq([])
  end

  it "saves dispersion (spread) values as string & decimal" do
    nct_id='NCT02958956'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    measurements=study.baseline_measurements.select{|x|
      x.title=='Age' && x.units=='Years' && x.dispersion_type=='Standard Deviation' && x.ctgov_group_code=='B2'}
    expect(measurements.size).to eq(1)
    bm=measurements.first
    expect(bm.param_value).to eq('59.7')
    expect(bm.param_value_num).to eq(59.7)
    expect(bm.dispersion_value).to eq('12.2')
    expect(bm.dispersion_value_num).to eq(12.2)
  end

  it "saves dispersion lower/upper values as decimal" do
    nct_id='NCT02708238'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    measurements=study.baseline_measurements.select{|x|
      x.title=='Age' && x.units=='Days' && x.dispersion_type=='Full Range' && x.ctgov_group_code=='B1'}
    expect(measurements.size).to eq(1)
    bm=measurements.first
    expect(bm.param_value).to eq('38')
    expect(bm.param_value_num).to eq(38)
    expect(bm.dispersion_lower_limit).to eq(14)
    expect(bm.dispersion_upper_limit).to eq(86)
  end
end
