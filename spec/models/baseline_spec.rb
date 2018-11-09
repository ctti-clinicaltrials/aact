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

  it "study should have expected baseline relationships" do
    ResultGroup.destroy_all
    BaselineMeasurement.destroy_all
    BaselineCount.destroy_all
    nct_id='NCT02028676'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    expect(ResultGroup.where('result_type=?','Baseline').size).to eq(10)
    expect(BaselineMeasurement.count).to eq(380)
    expect(BaselineMeasurement.first.nct_id).to eq(nct_id)
    expect(BaselineMeasurement.first.result_group.result_type).to eq('Baseline')
    expect(BaselineMeasurement.first.result_group.nct_id).to eq(nct_id)
    expect(BaselineCount.count).to eq(10)
    b10=BaselineCount.where('ctgov_group_code=?','B10').first
    expect(b10.nct_id).to eq(nct_id)
    expect(b10.count).to eq(3839)
    expect(b10.result_group.title).to eq('Total')
    expect(b10.result_group.description).to eq('Total of all reporting groups')
    expect(b10.scope).to eq('Overall')
    expect(b10.units).to eq('Participants')
    b3=BaselineCount.where('ctgov_group_code=?','B3').first
    expect(b3.nct_id).to eq(nct_id)
    expect(b3.count).to eq(397)
    expect(b3.scope).to eq('Overall')
    expect(b3.units).to eq('Participants')
    expect(b3.result_group.title).to eq('Arm A: Abacavir (ABC)+Lamivudine (3TC)+NNRTI')

    expect(study.baseline_population).to eq('All participants who were randomized were included except those who were randomised in error (main enrollment: 1 child HIV-uninfected, 2 on main phase of tuberculosis treatment; cotrimoxazole secondary randomization: 2 children receiving dapsone prophylaxis not cotrimoxazole).')
    expect(study.baseline_measurements.size).to eq(380);
    bm=study.baseline_measurements.select{|x|x.title=='Gender' && x.classification=='Female' && x.ctgov_group_code=='B1'}.first
    expect(bm.param_type).to eq('Number');
    expect(bm.category).to eq('');
    expect(bm.units).to eq('participants');
    expect(bm.param_value).to eq('308');
    expect(bm.param_value_num).to eq(308);
    bm3=study.baseline_measurements.select{|x|x.title=='Gender'  && x.classification=='Female' && x.ctgov_group_code=='B3'}.first
    expect(bm3.param_type).to eq('Number');
    expect(bm3.param_value).to eq('NA');
    expect(bm3.param_value_num).to eq(nil);
    expect(bm3.explanation_of_na).to eq('Different randomized comparison');
    expect(bm3.dispersion_upper_limit).to eq(nil);

    counts=BaselineCount.where('nct_id=?',nct_id)
    expect(counts.size).to eq(10);
    expect(study.baseline_counts.size).to eq(10);
    expect(study.baseline_counts.size).to eq(10);
    ba1=study.baseline_counts.select{|x|x.units=='Participants' && x.scope=='Overall' && x.ctgov_group_code=='B1'}.first
    ba3=study.baseline_counts.select{|x|x.units=='Participants' && x.scope=='Overall' && x.ctgov_group_code=='B3'}.first
    expect(ba1.count).to eq(606);
    expect(ba3.count).to eq(397);

    expect(study.result_groups.select{|x|x.result_type=='Baseline'}.size).to eq(10);
    bg1=study.result_groups.select{|x| x.result_type=='Baseline' && x.ctgov_group_code=='B1'}.first
    bg10=study.result_groups.select{|x| x.result_type=='Baseline' && x.ctgov_group_code=='B10'}.first

    expect(bg1.title).to eq('Clinically Driven Monitoring (CDM)');
    expect(bg10.title).to eq('Total')

    expect(bg1.description).to eq('Clinically Driven Monitoring (CDM): Participants were examined by a doctor and had routine full blood count with white cell differential, lymphocyte subsets (CD4, CD8), biochemistry tests (bilirubin, urea, creatinine, aspartate aminotransferase, alanine aminotransferase) at screening, randomisation (lymphocytes only), weeks 4, 8, and 12, then every 12 weeks. Screening results were used to assess eligibility. All subsequent results were only returned if requested for clinical management (authorised by centre project leaders); haemoglobin results at week 8 were automatically returned on the basis of early anaemia in a previous adult trial as were grade 4 laboratory toxicities (protocol safety criteria). Total lymphocytes and CD4 tests were never returned for CDM participants, but for all children other investigations (including tests from the routine panels) could be requested and concomitant drugs prescribed, as clinically indicated at extra patient-initiated or scheduled visits.')
    expect(bg10.description).to eq('Total of all reporting groups')
  end

  it "study should have baselines with expected dispersion value" do
    xml=Nokogiri::XML(File.read('spec/support/xml_data/NCT02389088.xml'))
    nct_id='NCT02389088'
    study=Study.new({xml: xml, nct_id: nct_id}).create
    baseline_array=study.baseline_measurements.select{|x| x.title=='Age' and x.ctgov_group_code=='B1'}
    expect(baseline_array.size).to eq(1)
    expect(baseline_array.first.units).to eq('years')
    expect(baseline_array.first.param_type).to eq('Mean')
    expect(baseline_array.first.param_value).to eq('26')
    expect(baseline_array.first.param_value_num).to eq(26)
    expect(baseline_array.first.dispersion_value).to eq('1.2')
    expect(baseline_array.first.dispersion_value_num).to eq(1.2)
    expect(baseline_array.first.dispersion_type).to eq('Standard Deviation')
    baseline_array=study.baseline_measurements.select{|x| x.title=='Gender' and x.ctgov_group_code=='B1'}
    expect(baseline_array.size).to eq(2)
    female_baseline=baseline_array.select{|x|x.classification=='Female'}.first
    male_baseline=baseline_array.select{|x|x.classification=='Male'}.first
    expect(female_baseline.units).to eq('participants')
    expect(female_baseline.param_type).to eq('Number')
    expect(female_baseline.param_value).to eq('9')
    expect(female_baseline.param_value_num).to eq(9)
    expect(female_baseline.result_group.description).to eq('9 PCOS women')

    # This is an example of why we might want to dispense with the attempt
    # to link all result-type rows to result_group
    # There's only 1 gtoup defined for baseline (B1: 9 PCOS women), but both
    # Male and Female measurements are associated with group code B1.

    expect(male_baseline.units).to eq('participants')
    expect(male_baseline.param_type).to eq('Number')
    expect(male_baseline.param_value).to eq('0')
    expect(male_baseline.param_value_num).to eq(0)
    expect(male_baseline.result_group.description).to eq('9 PCOS women')
  end

end
