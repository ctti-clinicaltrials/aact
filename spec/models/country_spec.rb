require 'rails_helper'

RSpec.describe Country, type: :model do
  context 'when only location_countries exist' do
    let!(:xml) {Nokogiri::XML(File.read('spec/support/xml_data/NCT00513591.xml'))}
    let!(:opts) {{xml: xml, nct_id: 'NCT00513591'}}
    let!(:country) {Country.create_all_from(opts)}
    let!(:test_country) {Country.first}

    it 'should return the expected country name' do
      expect(test_country.name).to eq('United States')
    end

    it 'should return a nil value for removed' do
      expect(test_country.removed).to eq(nil)
    end
  end

  it "saves multiple current and removed countries" do
    nct_id='NCT01642004'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.countries.size).to eq(25)
    expect(study.countries.select{|x|x.removed==true}.size).to eq(5)
    expect(study.countries.select{|x|x.name=='Peru' and x.removed==nil}.size).to eq(1)
    expect(study.countries.select{|x|x.name=='Peru' and x.removed==true}.size).to eq(0)
    expect(study.countries.select{|x|x.name=='Norway' and x.removed==true}.size).to eq(1)
  end

  it "has removed country" do
    nct_id='NCT02586688'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.countries.select{|x|x.removed==true}.first.name).to eq('Canada')
  end

  context 'when location_countries and removed_countries exist' do
    let!(:xml) {Nokogiri::XML(File.read('spec/support/xml_data/NCT02586688.xml'))}
    let!(:opts) {{xml: xml, nct_id: 'NCT02586688'}}
    let!(:country) {Country.create_all_from(opts)}
    let!(:test_country) {Country.last}
    let!(:second_test_country) {Country.first}

    it 'should return the correct number of countries' do
      country_count = Country.all.count
      expect(country_count).to eq(2)
    end

    it 'should return the expected removed_country name' do
      expect(test_country.name).to eq('Canada')
    end

    it 'should return the expected location_country name' do
      expect(second_test_country.name).to eq('United States')
    end

    it 'should return a value of true for removed for removed_countries' do
      expect(test_country.removed).to eq(true)
    end
  end

  context 'when country does not exist' do
    nct_id='NCT02389088'
    let!(:xml) {Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))}
    let!(:opts) {{xml: xml, nct_id: nct_id}}
    let!(:country) {Country.create_all_from(opts)}

    it 'should have nil value' do
      country = Country.first
      expect(country).to eq(nil)
    end
  end
end
