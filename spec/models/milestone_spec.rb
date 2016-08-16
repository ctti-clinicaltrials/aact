require 'rails_helper'

describe Milestone do
  it "study should have expected milestones" do
    nct_id='NCT02028676'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    expect(study.nct_id).to eq(nct_id)
    expect(Milestone.count).to eq(108)
    expect(study.milestones.size).to eq(108)

    p1_milestones=(study.milestones.select{|m|m.ctgov_group_code=='P1'})
    expect(p1_milestones.size).to eq(12)
    expect(p1_milestones.first.result_group.title).to eq('Clinically Driven Monitoring (CDM)')
    expect(p1_milestones.last.result_group.description).to eq('Clinically Driven Monitoring (CDM): Participants were examined by a doctor and had routine full blood count with white cell differential, lymphocyte subsets (CD4, CD8), biochemistry tests (bilirubin, urea, creatinine, aspartate aminotransferase, alanine aminotransferase) at screening, randomisation (lymphocytes only), weeks 4, 8, and 12, then every 12 weeks. Screening results were used to assess eligibility. All subsequent results were only returned if requested for clinical management (authorised by centre project leaders); haemoglobin results at week 8 were automatically returned on the basis of early anaemia in a previous adult trial as were grade 4 laboratory toxicities (protocol safety criteria). Total lymphocytes and CD4 tests were never returned for CDM participants, but for all children other investigations (including tests from the routine panels) could be requested and concomitant drugs prescribed, as clinically indicated at extra patient-initiated or scheduled visits.')

    p1_milestone_period=p1_milestones.select{|x|x.period=='Initial Enrolment: CDM vs LCM'}
		expect(p1_milestone_period.size).to eq(3)
    p1_milestone=p1_milestones.select{|x|x.title=='STARTED' and x.period=='Initial Enrolment: CDM vs LCM'}.first
    expect(p1_milestone.description).to eq('Factorial randomization at enrolment: Number of eligible children randomized to this group in ARROW')
    expect(p1_milestone.participant_count).to eq(606)
  end

end
