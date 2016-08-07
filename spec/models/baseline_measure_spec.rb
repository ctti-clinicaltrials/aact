require 'rails_helper'

describe Study do
  it "study should have expected baseline measure values" do
    xml=Nokogiri::XML(File.read('spec/support/xml_data/NCT02028676.xml'))
    nct_id='NCT02028676'
    study=Study.new({xml: xml, nct_id: 'NCT02028676'}).create

    expect(study.nct_id).to eq(nct_id)
    expect(study.baseline_measures.size).to eq(390)
    baselines=(study.baseline_measures.select{|m|m.category=='Female'})
    expect(baselines.size).to eq(40)
    female_baselines=(baselines.select{|m|m.title=='Gender'})
    expect(female_baselines.size).to eq(10)
    b1_baselines=(study.baseline_measures.select{|m|m.ctgov_group_code=='B1'})
    expect(b1_baselines.size).to eq(39)

    baseline_title="Weight-for-age Z-score: Period 3 (randomization to once vs twice daily ABC+3TC)"
    period3_zscore=[]
    study.baseline_measures.each{|x|period3_zscore << x if x.title==baseline_title}
    expect(period3_zscore.size).to eq(10)

    baseline_title="Weight-for-age Z-score: Period 4 (randomization to stop versus continue cotrimoxazole)"
    period4_zscore=[]
    study.baseline_measures.each{|x|period4_zscore << x if x.title==baseline_title}
    expect(period4_zscore.size).to eq(10)
    b1_male_baselines=(b1_baselines.select{|m|m.category=='Male' and m.title=='Gender'})
    expect(b1_male_baselines.size).to eq(1)
    expect(b1_male_baselines.first.param_value).to eq('298')
    measure=(study.baseline_measures.select{|m| m.dispersion_type=='Inter-Quartile Range'}).first
  end

end
