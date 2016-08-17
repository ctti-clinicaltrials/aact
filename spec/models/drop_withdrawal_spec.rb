require 'rails_helper'

describe DropWithdrawal do
  it "study should have expected milestones" do
    nct_id='NCT00023673'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    expect(study.nct_id).to eq(nct_id)
    expect(DropWithdrawal.count).to eq(8)
    expect(study.drop_withdrawals.size).to eq(8)

    p1=(study.drop_withdrawals.select{|m|m.ctgov_group_code=='P1'})
    expect(p1.size).to eq(2)
    expect(p1.first.result_group.title).to eq('Phase I: 75.25 Gy/36 fx + Chemotherapy')
    expect(p1.last.result_group.description).to eq('Phase I: Three-dimensional conformal radiation therapy (3DRT) of 75.25 Gy given in 36 fractions (2.15 Gy per fraction) with concurrent chemotherapy consisting of weekly paclitaxel at 50mg/m2 and carboplatin at area under the curve 2mg/m2. Adjuvant systemic chemotherapy (two cycles of paclitaxel and carboplatin) following completion of RT was optional.')

    reason=p1.select{|x|x.reason=='Ineligible / no protocol treatment'}.first
    expect(reason.participant_count).to eq(0)
    p4=(study.drop_withdrawals.select{|m|m.ctgov_group_code=='P4' and m.reason=='Patient withdrew consent'})
    expect(p4.size).to eq(1)
    expect(p4.first.participant_count).to eq(1)
    expect(p4.first.result_group.title).to eq('Phase II: 74 Gy/37 fx + Chemotherapy')
    expect(p4.first.result_group.description).to eq('Phase II: Three-dimensional conformal radiation therapy (3DRT) of 74 Gy given in 37 fractions (2.0 Gy per fraction) with concurrent chemotherapy consisting of weekly paclitaxel at 50mg/m2 and carboplatin at area under the curve 2mg/m2. Adjuvant systemic chemotherapy (two cycles of paclitaxel and carboplatin) following completion of RT was optional.')
  end

end
