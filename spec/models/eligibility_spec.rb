require 'rails_helper'

describe Eligibility do
  it "study should have expected eligibility data" do
    nct_id='NCT02028676'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.eligibility.gender).to eq('Both')
    expect(study.eligibility.minimum_age).to eq('3 Months')
    expect(study.eligibility.maximum_age).to eq('17 Years')
    expect(study.eligibility.healthy_volunteers).to eq('No')
  end

  it "study should have expected eligibility data" do
    nct_id='NCT00513591'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.eligibility.population).to eq('Pregnant women with autoimmune disease.')
    expect(study.eligibility.sampling_method).to eq('Non-Probability Sample')
    expect(study.eligibility.gender).to eq('Female')
    expect(study.eligibility.minimum_age).to eq('18 Years')
    expect(study.eligibility.maximum_age).to eq('N/A')
    expect(study.eligibility.healthy_volunteers).to eq('Accepts Healthy Volunteers')
    expect(study.eligibility.criteria.gsub!(/\s+/, "")).to eq(nct00513591_criteria.gsub!(/\s+/, ""))
  end

  def nct00513591_criteria
    "Inclusion Criteria: - 18 years of age or older - Desire for pregnancy within 6 months or currently pregnant - Women with systemic autoimmune disease, including: - Lupus (systemic lupus erythematosus or cutaneous lupus) - Antiphospholipid Syndrome or positive antiphospholipid antibodies - Rheumatoid Arthritis - Scleroderma (systemic sclerosis) - Sjogren's Syndrome - Inflammatory Arthritis (including Psoriatic Arthritis and Ankylosing Spondylitis) - Undifferentiated Connective Tissue Disease (UCTD) - Vasculitis - Myositis (Polymyositis or Dermatomyositis) - Positive Ro/SSA or La/SSB antibodies Exclusion Criteria: - Unable to speak English - Unable to provide informed consent - Unable to travel to Duke University for follow-up visits"
  end

end
