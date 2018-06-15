require 'rails_helper'


describe Study do
  it "handles last known status" do
    nct_id='NCT02591940'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.last_known_status).to eq('Enrolling by invitation')
  end

  it "handles expanded access fields" do
    nct_id='NCT03133988'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.expanded_access_type_individual).to be true
    expect(study.expanded_access_type_intermediate).to be nil
    expect(study.expanded_access_type_treatment).to be nil

    nct_id='NCT03147742'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.expanded_access_type_individual).to be nil
    expect(study.expanded_access_type_intermediate).to be true
    expect(study.expanded_access_type_treatment).to be nil

    nct_id='NCT03245528'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.expanded_access_type_individual).to be nil
    expect(study.expanded_access_type_intermediate).to be nil
    expect(study.expanded_access_type_treatment).to be true
    expect(study.study_first_submitted_qc_date).to eq('August 7, 2017'.to_date)
  end

  it "saves expanded access info correctly"  do
    nct_id='NCT01220531'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.study_type).to eq('Expanded Access')
    expect(study.expanded_access_type_intermediate).to eq(true)
    expect(study.expanded_access_type_treatment).to eq(true)
    expect(study.expanded_access_type_individual).to eq(nil)
  end

  it "our validation study should have correct attribs" do
    nct_id='NCT02654730'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.source).to eq('London School of Hygiene and Tropical Medicine')
    expect(study.overall_status).to eq('Terminated')
  end

  it "saves is_unapproved_device" do
    nct_id='NCT02988895'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.is_unapproved_device).to be(false)
    expect(study.is_ppsd).to be(false)
    expect(study.is_us_export).to be(false)
  end

  it "saves expanded access information correctly" do
    nct_id='NCT02970669'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.has_expanded_access).to be(true)
    #  These tags were released 1/11/17, but as of 8/9/17, no studies have this info.  Sent email to NLM asking if these tags are actie.
#    expect(study.expanded_access_type_individual).to be(true)
#    expect(study.expanded_access_type_intermediate).to be(true)
#    expect(study.expanded_access_type_treatment).to be(true)
  end

  it "should have correct date attribs" do
    nct_id='NCT00023673'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    CalculatedValue.new.create_from(study).save!
    expect(study.start_month_year).to eq('July 2001')
    expect(study.start_date.strftime('%m/%d/%Y')).to eq('07/31/2001')
    expect(study.completion_month_year).to eq('November 2013')
    expect(study.completion_date.strftime('%m/%d/%Y')).to eq('11/30/2013')
    expect(study.primary_completion_month_year).to eq('January 2009')
    expect(study.primary_completion_date.strftime('%m/%d/%Y')).to eq('01/31/2009')
    expect(study.verification_month_year).to eq('November 2017')
    expect(study.verification_date.strftime('%m/%d/%Y')).to eq('11/30/2017')

    expect(study.study_first_submitted_date).to eq('September 13, 2001'.to_date)
    expect(study.results_first_submitted_date).to eq('February 12, 2014'.to_date)
    expect(study.last_update_submitted_date).to eq('November 27, 2017'.to_date)

    expect(study.study_first_submitted_qc_date).to eq('April 8, 2003'.to_date)
    expect(study.study_first_posted_date).to eq('April 9, 2003'.to_date)
    expect(study.results_first_submitted_qc_date).to eq('February 12, 2014'.to_date)
    expect(study.results_first_posted_date).to eq('March 27, 2014'.to_date)
    expect(study.disposition_first_submitted_qc_date).to eq(''.to_date)
    expect(study.disposition_first_posted_date).to eq(''.to_date)
    expect(study.last_update_submitted_qc_date).to eq('November 27, 2017'.to_date)
    expect(study.last_update_posted_date).to eq('December 22, 2017'.to_date)

    expect(study.study_first_posted_date_type).to eq('Estimate')
    expect(study.results_first_posted_date_type).to eq('Estimate')
    expect(study.disposition_first_posted_date_type).to be nil
    expect(study.last_update_posted_date_type).to eq('Actual')

    expect(study.start_date).to eq(study.start_month_year.to_date.end_of_month)
    expect(study.verification_date).to eq(study.verification_month_year.to_date.end_of_month)
    expect(study.completion_date).to eq(study.completion_month_year.to_date.end_of_month)
    expect(study.primary_completion_date).to eq(study.primary_completion_month_year.to_date.end_of_month)

    expect(study.result_contacts.first.name).to eq('Wendy Seiferheld')
    expect(study.result_contacts.first.organization).to eq('Radiation Therapy Oncology Group')
    expect(study.result_contacts.first.email).to eq('wseiferheld@acr.org')

    expect(study.design_groups.size).to eq(4)
    g=study.design_groups.select{|x|x.title=='Phase I: 75.25 Gy/36 fx + chemotherapy'}.first
    expect(g.description).to eq('Phase I: Three-dimensional conformal radiation therapy (3DRT) of 75.25 Gy given in 36 fractions (2.15 Gy per fraction) with concurrent chemotherapy consisting of weekly paclitaxel at 50mg/m2 and carboplatin at area under the curve 2mg/m2. Adjuvant systemic chemotherapy (two cycles of paclitaxel and carboplatin) following completion of RT was optional.')
    expect(g.group_type).to eq('Experimental')

    # verify sponsor info
    expect(study.sponsors.size).to eq(2)
    lead=study.sponsors.select{|x|x.lead_or_collaborator=='lead'}.first
    collaborator=study.sponsors.select{|x|x.lead_or_collaborator=='collaborator'}.first
    expect(lead.name).to eq('Radiation Therapy Oncology Group')
    expect(lead.agency_class).to eq('Other')
    expect(collaborator.name).to eq('National Cancer Institute (NCI)')
    expect(collaborator.agency_class).to eq('NIH')

    nct_id='NCT01642004'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.disposition_first_submitted_qc_date).to eq('November 17, 2015'.to_date)
    expect(study.disposition_first_posted_date).to eq('December 16, 2015'.to_date)

  end

  it "should have expected date values" do
    nct_id='NCT02260193'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.disposition_first_submitted_date).to eq('October 23, 2015'.to_date)
  end

  context 'when loading a study' do
    nct_id='NCT02830269'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    it 'should have expected start date values' do
      expect(study.start_date.strftime('%m/%d/%Y')).to eq('08/18/2016')
      expect(study.start_date_type).to eq('Actual')
    end
  end

  context 'when loading a study' do
    nct_id='NCT01174550'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    it 'should have expected sharing ipd values' do
      expect(study.plan_to_share_ipd).to eq('Yes')
      expect(study.plan_to_share_ipd_description).to eq('Data will be submitted to the NHLBI according to their guidelines which state"The data sets must be submitted to the study NHLBI study Program Official no later than 3 years after the end of the clinical activity (final patient follow-up, etc.) or 2 years after the main paper of the trial has been published, whichever comes first. Data are prepared by the study coordinating center and sent to the PO for review prior to release."')
    end
  end

  context 'study has limitations and caveats' do
    nct_id='NCT00023673'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    it 'should have expected limitations and caveats value' do
      expect(study.limitations_and_caveats).to eq('This study was originally designed to escalate 3DRT via increasing doses per fraction. However, due to excessive toxicity at dose level 1 (75.25 Gy, 2.15 Gy/fraction), the protocol was amended in January 2003 to de-escalate 3DRT dose.')
    end

  end

  context 'when patient data section does not exist' do
    nct_id='NCT02260193'
    xml=Nokogiri::XML(File.read('spec/support/xml_data/example_study.xml'))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    it 'should return empty string for sharing ipd value' do
      expect(study.plan_to_share_ipd).to eq(nil)
    end

    it 'should return empty string for ipd description value' do
      expect(study.plan_to_share_ipd_description).to eq(nil)
    end
  end
end
