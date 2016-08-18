require 'rails_helper'

describe Intervention do

  it "study should have interventions linked to design_groups" do
    nct_id='NCT00023673'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    i=study.interventions.select{|x|x.name=='carboplatin'}.first
    expect(i.intervention_type).to eq('Drug')
    expect(i.design_group_interventions.size).to eq(4)
    expect(i.design_group_interventions.size).to eq(4)
    g_array=i.design_group_interventions.select{|x|x.design_group.title=='Phase I: 75.25 Gy/36 fx + chemotherapy'}
    expect(g_array.size).to eq(1)
    g=g_array.first
    expect(g.design_group.description).to eq('Phase I: Three-dimensional conformal radiation therapy (3DRT) of 75.25 Gy given in 36 fractions (2.15 Gy per fraction) with concurrent chemotherapy consisting of weekly paclitaxel at 50mg/m2 and carboplatin at area under the curve 2mg/m2. Adjuvant systemic chemotherapy (two cycles of paclitaxel and carboplatin) following completion of RT was optional.')
    expect(g.design_group.group_type).to eq('Experimental')
  end

end
