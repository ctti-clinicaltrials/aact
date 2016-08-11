require 'rails_helper'

describe BaselineMeasure do
  it "study should have expected baseline measure values" do
    nct_id='NCT02028676'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    expect(study.nct_id).to eq(nct_id)
    expect(BaselineMeasure.count).to eq(390)
    expect(study.baseline_measures.size).to eq(390)

    baselines=(study.baseline_measures.select{|m|m.title=='Gender'})
    expect(baselines.size).to eq(20)

    female_baselines=(baselines.select{|m|m.category=='Female'})
    expect(female_baselines.size).to eq(10)
    female_b1_array=(female_baselines.select{|m|m.ctgov_group_code=='B1'})
    expect(female_b1_array.size).to eq (1)
    female_b1=female_b1_array.first
    expect(female_b1.description).to eq('')
    expect(female_b1.result_group.result_type).to eq('Baseline Measure')
    expect(female_b1.param_type).to eq('Number')
    expect(female_b1.param_value).to eq('308')
    expect(female_b1.units).to eq('participants')
    expect(female_b1.explanation_of_na).to eq('')
    expect(female_b1.result_group.ctgov_group_code).to eq(female_b1.ctgov_group_code)
    expect(female_b1.result_group.title).to eq('Clinically Driven Monitoring (CDM)')
    expect(female_b1.result_group.description).to eq('Clinically Driven Monitoring (CDM): Participants were examined by a doctor and had routine full blood count with white cell differential, lymphocyte subsets (CD4, CD8), biochemistry tests (bilirubin, urea, creatinine, aspartate aminotransferase, alanine aminotransferase) at screening, randomisation (lymphocytes only), weeks 4, 8, and 12, then every 12 weeks. Screening results were used to assess eligibility. All subsequent results were only returned if requested for clinical management (authorised by centre project leaders); haemoglobin results at week 8 were automatically returned on the basis of early anaemia in a previous adult trial as were grade 4 laboratory toxicities (protocol safety criteria). Total lymphocytes and CD4 tests were never returned for CDM participants, but for all children other investigations (including tests from the routine panels) could be requested and concomitant drugs prescribed, as clinically indicated at extra patient-initiated or scheduled visits.')

    gender_period_2=study.baseline_measures.select{|x|x.title=='Gender, Male/Female: Period 2 (trial enrollment, induction ART)'}
    expect(gender_period_2.size).to eq(20)
    females=gender_period_2.select{|x|x.category=='Female'}
    expect(females.size).to eq(10)
    females_b10=females.select{|x|x.ctgov_group_code=='B10'}
    expect(females_b10.size).to eq(1)
    female_b10=females_b10.first

    expect(female_b10.units).to eq('participants')
    expect(female_b10.param_type).to eq('Number')
		expect(female_b10.param_value).to eq('NA')
    expect(female_b10.explanation_of_na).to eq('Total not calculated because data are not available (NA) in one or more arms.')

		expect(female_b10.population).to eq('All participants who were randomized were included except those who were randomised in error (main enrollment: 1 child HIV-uninfected, 2 on main phase of tuberculosis treatment; cotrimoxazole secondary randomization: 2 children receiving dapsone prophylaxis not cotrimoxazole).')

    baseline_title="Weight-for-age Z-score: Period 3 (randomization to once vs twice daily ABC+3TC)"
    period3_zscore=[]
    study.baseline_measures.each{|x|period3_zscore << x if x.title==baseline_title}
    expect(period3_zscore.size).to eq(10)

    baseline_title="Weight-for-age Z-score: Period 4 (randomization to stop versus continue cotrimoxazole)"
    period4_zscore=[]
    study.baseline_measures.each{|x|period4_zscore << x if x.title==baseline_title}
    expect(period4_zscore.size).to eq(10)

    b1_baselines=study.baseline_measures.select{|x|x.ctgov_group_code=='B1'}
    b1_cd4_tcell=(b1_baselines.select{|m| m.title=='CD4 T cell percentage'})
    expect(b1_cd4_tcell.size).to eq(1)
    expect(b1_cd4_tcell.first.param_type).to eq('Median')
    expect(b1_cd4_tcell.first.param_value).to eq('12.5')
    measure=(study.baseline_measures.select{|m| m.dispersion_type=='Inter-Quartile Range'}).first
    expect(b1_cd4_tcell.first.dispersion_lower_limit).to eq('7.5')
    expect(b1_cd4_tcell.first.dispersion_upper_limit).to eq('17.3')
    expect(b1_cd4_tcell.first.units).to eq('percentage of total lymphocytes')

    b1_age=(b1_baselines.select{|m|m.title=='Age'})
    expect(b1_age.size).to eq(1)
		expect(b1_age.first.description).to eq('Age at trial enrollment (antiretroviral therapy initiation).')
		expect(b1_age.first.units).to eq('years')
		expect(b1_age.first.param_type).to eq('Median')
    expect(b1_age.first.param_value).to eq('5.9')
    expect(b1_age.first.dispersion_lower_limit).to eq('2.2')
    expect(b1_age.first.dispersion_upper_limit).to eq('9.2')

  end

  it "study should have baseline measure with expected dispersion value" do
    xml=Nokogiri::XML(File.read('spec/support/xml_data/NCT02389088.xml'))
    nct_id='NCT02389088'
    study=Study.new({xml: xml, nct_id: nct_id}).create
    baseline_array=study.baseline_measures.select{|x| x.title=='Age' and x.population=='9 PCOS women' and x.ctgov_group_code=='B1'}
    expect(baseline_array.size).to eq(1)
    expect(baseline_array.first.units).to eq('years')
    expect(baseline_array.first.param_type).to eq('Mean')
    expect(baseline_array.first.param_value).to eq('26')
    expect(baseline_array.first.dispersion_value).to eq('1.2')
    expect(baseline_array.first.dispersion_type).to eq('Standard Deviation')
	end

end
