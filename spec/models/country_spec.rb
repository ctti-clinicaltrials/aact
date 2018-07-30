require 'rails_helper'

RSpec.describe Country, type: :model do
  context 'when only location_countries exist' do

    it 'should return the expected country name' do
      Country.destroy_all
      nct_id='NCT00513591'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      opts={xml: xml, nct_id: nct_id}
      Country.create_all_from(opts)
      countries = Country.where('nct_id=?', nct_id)
      expect(countries.size).to eq(1)
      test_country=countries.first
      expect(test_country.name).to eq('United States')
      expect(test_country.removed).to eq(nil)
    end

    it "saves multiple current and removed countries" do
      nct_id='NCT01642004'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      study=Study.new({xml: xml, nct_id: nct_id}).create
      expect(study.countries.size).to eq(26)
      expect(study.countries.select{|x|x.removed==true}.size).to eq(6)
      expect(study.countries.select{|x|x.name=='Peru' and x.removed==nil}.size).to eq(1)
      expect(study.countries.select{|x|x.name=='Peru' and x.removed==true}.size).to eq(0)
      expect(study.countries.select{|x|x.name=='Norway' and x.removed==true}.size).to eq(1)
    end

    it "has removed country" do
      nct_id='NCT02586688'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      opts={xml: xml, nct_id: nct_id}
      Country.create_all_from(opts)

      all_countries = Country.where('nct_id=?', nct_id)
      removed_countries = all_countries.select{|c|c.removed == true}
      not_removed_countries = all_countries.select{|c|c.removed != true}

      # it should return the expected removed_country name' do
      expect(all_countries.size).to eq(2)
      expect(removed_countries.size).to eq(1)
      expect(not_removed_countries.size).to eq(1)

      expect(removed_countries.first.name).to eq('Canada')
      expect(not_removed_countries.first.name).to eq('United States')
    end

  end

  context 'when country does not exist' do
    it 'should return nothing' do
      nct_id='NCT02389088'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      opts={xml: xml, nct_id: nct_id}
      Country.create_all_from(opts)
      countries = Country.where('nct_id=?', nct_id)
      expect(countries.size).to eq(0)
    end
  end
end
