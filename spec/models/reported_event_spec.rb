require 'rails_helper'
describe ReportedEvent do
  it "should have expected values" do
		nct_id='NCT00023673'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    #g1=study.reported_events.select{|x|x.ctgov_group_code=='E1'}

    e1=study.reported_events.select{|x|x.ctgov_group_code=='E1'}
    e2=study.reported_events.select{|x|x.ctgov_group_code=='E2'}
    expect(e1.size).to eq(166)
    expect(e2.size).to eq(166)

    serious=study.reported_events.select{|x|x.ctgov_group_code=='E2' and x.organ_system=='Total' and x.event_type=='serious'}
    expect(serious.size).to eq(1)
    e2_serious=serious.first
    expect(e2_serious.subjects_affected).to eq(36)
    expect(e2_serious.subjects_at_risk).to eq(53)
    expect(e2_serious.default_vocab).to eq('CTCAE (2.0)')
    expect(e2_serious.default_assessment).to eq('Non-systematic Assessment')
    expect(e2_serious.adverse_event_term).to eq('Total, serious adverse events')
    expect(e2_serious.group.ctgov_group_id).to eq(e2_serious.ctgov_group_code)

    e1_serious_cardiac_array=e1.select{|x|x.event_type=='serious' and x.organ_system=='Cardiac disorders'}
    expect(e1_serious_cardiac_array.size).to eq(3)
    e1_serious_cardiac=e1_serious_cardiac_array.select{|x|x.adverse_event_term=='Arrhythmia NOS'}.first
    expect(e1_serious_cardiac.subjects_affected).to eq(0)
    expect(e1_serious_cardiac.subjects_at_risk).to eq(8)

    events_with_assessment=study.reported_events.select{|x| x.assessment=='Systematic Assessment'}
    events_with_assessment=study.reported_events.select{|x| x.adverse_event_term=='Late RT Toxicity: Bone'}

    event=events_with_assessment.select{|x| x.adverse_event_term=='Late RT Toxicity: Bone' and x.ctgov_group_code=='E2'}.first
		expect(event.subjects_affected).to eq(1)
		expect(event.subjects_at_risk).to eq(53)
		expect(event.vocab).to eq('RTOG/EORTC Late Tox.')
	end

  it "should have expected values" do
    nct_id='NCT02028676'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    other_events=study.reported_events.select{|x|x.event_type=='other'}
    expect(other_events.size).to eq(36)
    expect(other_events.select{|x|x.frequency_threshold==5}.size).to eq(36)
    expect(other_events.select{|x|x.default_vocab=='Trial-specific'}.size).to eq(36)
    expect(other_events.select{|x|x.default_assessment=='Systematic Assessment'}.size).to eq(36)

	end
end

