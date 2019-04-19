require 'rails_helper'

RSpec.describe Criterium, type: :model do
  context 'when criteria provided' do

    it 'should handle upper/lower case inc/excl labels' do
      described_class.destroy_all
      nct_id='NCT00151216'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      opts={xml: xml, nct_id: nct_id}
      described_class.create_all_from(opts)
      inclusion = described_class.where(criterium_type: 'inclusion')
      exclusion = described_class.where(criterium_type: 'exclusion')
      expect(inclusion.size).to eq(6)
      expect(exclusion.size).to eq(6)
      "Inclusion Criteria:
      - A definitive diagnosis of late infantile neuronal ceroid lipofuscinosis, based on clinical phenotype and genotype, with CLN2 gene mutations known to be associated with the disease.
      - All subjects will be naive, i.e., they have not previously participated in a gene therapy study for LINCL.
      - Parents of study participants must agree to comply in good faith with the conditions of the study, including attending all of the required baseline and follow-up assessments.
      - Both parents or legal guardians must give consent for their child's participation in the research study.
      - For group A, subjects will have a LINCL average total disability score 0 to 4, the severe form of the disease.
      - For group B, subjects will have a LINCL average total disability score 5 to 6, a moderate form of the disease.
      Exclusion criteria
      - Other significant medical or neurological conditions may disqualify the patient from participation in this study, particularly those which would create an unacceptable operative risk or risk to receiving the AAV2CUhCLN2 vector. Examples include malignancy (other than skin cancer), congenital heart disease, liver or renal failure, or seropositive for HIV. Each case will be individually reviewed and the final decision shall rest with the Eligibility Committee comprised on three physicians other than the Principal Investigator, including a pediatric neurosurgeon, pediatric neurologist and general pediatrician.
      - Individuals without adequate control of seizures (i.e., a seizure score <3 on the CNS Disability Scoring System for Late Infantile Neuronal Ceroid Lipofuscinosis).
      - Individuals with heart disease that would be a risk for anesthesia.
      - History of hemorrhage or major risk factors for hemorrhage (e.g., abnormally low platelet counts).
      - Concurrent participation in any other FDA approved Investigational New Drug clinical protocol is not allowed, although the Principal Investigator will work with other doctors to accommodate specific requests (e.g., a study of nutritional supplements probably would not be a disqualification).
      - Individuals who have a (1) heart pacemaker and/or related implants, (2) metal fragment/chip in the eye or other sites, (3) an aneurysm clip in their brain, and (4) metallic inner ear implants."
    end

    it 'should handle when inc/excl headers are unusual' do
      described_class.destroy_all
      nct_id='NCT03424005'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      opts={xml: xml, nct_id: nct_id}
      described_class.create_all_from(opts)
      inclusion = described_class.where(criterium_type: 'inclusion')
      exclusion = described_class.where(criterium_type: 'exclusion')
      expect(inclusion.size).to eq(21)
      expect(exclusion.size).to eq(22)

"Inclusion Criteria Stage 1
- ECOG Performance Status of 0 or 1
- Metastatic or inoperable locally advanced, histologically documented TNBC (absence of HER2, ER, and PR expression)
- Radiologic/objective evidence of recurrence or disease progression after chemotherapy for a total of one line of therapy for inoperable locally advanced or metastatic breast cancer
- Availability of a representative tumor specimen that is suitable for determination of PD-L1 and/or additional biomarker status via central testing
- Eligible for capecitabine monotherapy
- Life expectancy =/> 3 months, as determined by the investigator
- Tumor accessible for biopsy
- For women of childbearing potential: agreement to remain abstinent (refrain from heterosexual intercourse) or use contraceptive measures and agreement to refrain from breastfeeding and donating eggs as outlined for each specific treatment arm
- For men: agreement to remain abstinent (refrain from heterosexual intercourse) or use contraceptive measures, and agreement to refrain from donating sperm, as outlined for each specific treatment arm
- Adequate hematologic and end-organ function, laboratory test results, obtained within 14 days prior to initiation of study treatment.
- Negative HIV test at screening
- Negative hepatitis B surface antigen test
- Negative total hepatitis B core antibody (HBcAb)
- Negative hepatitis C virus (HCV) antibody test at screening
- Measurable disease (at least one target lesion) Inclusion criteria stage 2
- ECOG Performance Status of 0, 1, or 2
      - Patients randomly allocated to the control arm during Stage 1: ability to initiate Stage 2 treatment within 3 months after experiencing unacceptable toxicity, provided that Medical Monitor approval for entry into Stage 2 is obtained, or disease progression per RECIST v1.1 while receiving control treatment
      - Patients randomly allocated to an experimental arm during Stage 1: ability to initiate Stage 2 treatment within 3 months after experiencing unacceptable toxicity not related to atezolizumab, disease progression per RECIST v1.1, or loss of clinical benefit as determined by the investigator (see Section 3.1.1.1 for details) while receiving Stage 1 treatment
      - Availability of a tumor specimen from a biopsy performed upon discontinuation of Stage 1 (if deemed clinically feasible by the investigator)

      Exclusion Criteria for Stage 1
      - Prior treatment with any of the Stage 1 protocol-specified study treatments included in arms that are open at the time of screening, with the exception of capecitabine
      - Treatment with investigational therapy within 28 days prior to initiation of study treatment
      - Inability to swallow medication or malabsorption condition that would alter the absorption of orally administered medications
      - Treatment with sorivudine or its chemically related analogues, such as brivudine
      - History of severe and unexpected reactions to fluoropyrimidine therapy
      - Uncontrolled pleural effusion, pericardial effusion, or ascites requiring recurrent drainage procedures (once monthly or more frequently)
      - Uncontrolled tumor-related pain
      - Symptomatic, untreated, or actively progressing CNS metastases
      - History of leptomeningeal disease
      - Active or history of autoimmune disease or immune deficiency
      - History of idiopathic pulmonary fibrosis, organizing pneumonia (e.g., bronchiolitis obliterans), drug-induced pneumonitis, or idiopathic pneumonitis, or evidence of active pneumonitis on screening chest computed tomography (CT) scan History of radiation pneumonitis in the radiation field (fibrosis) is permitted.
      - Active tuberculosis
      - Severe infection within 4 weeks prior to initiation of study treatment
      - Treatment with therapeutic oral or IV antibiotics within 2 weeks prior to initiation of study treatment
      - Significant cardiovascular disease
      - Prior allogeneic stem cell or solid organ transplantation
      - History of malignancy other than breast cancer within 2 years prior to screening, with the exception of those with a negligible risk of metastasis or death
      - Treatment with systemic immunosuppressive medication (including, but not limited to, corticosteroids, cyclophosphamide, azathioprine, methotrexate, thalidomide, and anti-tumor necrosis factor alpha agents) within 2 weeks prior to initiation of study treatment, or anticipation of need for systemic immunosuppressive medication during the course of the study
      - Pregnancy or breastfeeding, or intention of becoming pregnant during the study
      - Additional drug-specific exclusion criteria might apply."




    end

    it 'should handle studies that only have inclusion criteria' do
      described_class.destroy_all
      sample1_name = "Women of childbearing potential must have a negative serum pregnancy test within 2 weeks prior to registration; patients that are pregnant or breast feeding are excluded; a female of childbearing potential is any woman, regardless of sexual orientation or whether they have undergone tubal ligation, who meets the following criteria:"
      nct_id= 'NCT02465060'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      opts={xml: xml, nct_id: nct_id}
      described_class.create_all_from(opts)
      inclusion = described_class.where(criterium_type: 'inclusion')
      exclusion = described_class.where(criterium_type: 'exclusion')
      expect(exclusion.size).to eq(0)
      expect(inclusion.size).to eq(82)
      # should strip off leading ' - '
      sample = described_class.where('order_number=1 and parent_id is null').first
      expect(sample.name).to eq(sample1_name)
      # should link children criteria to appropriate parent
      children = described_class.where('parent_id = ?', sample.id)
      expect(children.size).to eq(2)
      # should link children criteria to another child criterium where appropriate
      parent_sample = described_class.where('name=?',"Patients must have an electrocardiogram (ECG) within 8 weeks prior to registration to screening step and must meet the following cardiac criteria:").first
      child_sample = described_class.where('name=?',"Resting corrected QT interval (QTc) =< 480 msec").first
      expect(child_sample.criterium_type).to eq('inclusion')
      grandchild_sample = described_class.where('name=?',"NOTE: If the first recorded QTc exceeds 480 msec, two additional, consecutive ECGs are required and must result in a mean resting QTc =< 480 msec; it is recommended that there are 10-minute (+/- 5 minutes) breaks between the ECGs").first
      expect(child_sample.parent_id).to eq(parent_sample.id)
      expect(grandchild_sample.parent_id).to eq(child_sample.id)
    end

    it 'should parse inclusion section and save each one' do
      described_class.destroy_all
      nct_id='NCT03599518'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      opts={xml: xml, nct_id: nct_id}
      described_class.create_all_from(opts)

      inclusion = described_class.where(criterium_type: 'inclusion')
      exclusion = described_class.where(criterium_type: 'exclusion')
      expect(exclusion.size).to eq(23)
      expect(inclusion.size).to eq(12)
      incl_with_parents=inclusion.select{|x| !x.parent_id.nil?}
      excl_with_parents=exclusion.select{|x| !x.parent_id.nil?}
      expect(incl_with_parents.size).to eq(2)
      expect(excl_with_parents.size).to eq(8)
      sample=inclusion.first
      expect(sample.name).to eq('Has histologically or cytologically documented adenocarcinoma NSCLC')
      expect(sample.downcase_name).to eq('has histologically or cytologically documented adenocarcinoma nsclc')
      expect(sample.order_number).to eq(1)
      sample=described_class.where('criterium_type=? and order_number=3','inclusion').first
      expect(sample.name).to eq('Has acquired resistance to EGFR tyrosine kinase inhibitor (TKI) according to the Jackman criteria (PMID: 19949011):')
      expect(sample.parent_id).to be(nil)
    end

    xit 'should handle studies that specify diff types of criteria' do
      'NCT01220531 Transplant Inclusion:'
      'NCT02260193  Key Inclusion & Key Exclusion Criteria'
    end

    it 'should handle studies with criteria all on one line' do
      described_class.destroy_all
      nct_id='NCT03840122'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      opts={xml: xml, nct_id: nct_id}
      described_class.create_all_from(opts)

      inclusion = described_class.where(criterium_type: 'inclusion')
      exclusion = described_class.where(criterium_type: 'exclusion')
      expect(exclusion.size).to eq(4)
      expect(inclusion.size).to eq(4)

      sample = inclusion.select{|x| x.order_number == 1}.first
      expect(sample.name).to eq('Patient is over the age of 21')
      sample = exclusion.select{|x| x.order_number == 1}.first
      expect(sample.name).to eq('Patient is under the age of 21')

      'NCT03720470 has both inclusion & exclusion all on one line'
    end

    it 'should handle studies with criteria specifies neither inclusion or exclusion' do
      "NCT02481830 doesn't specify inclusion or exclusion"
      described_class.destroy_all
      nct_id='NCT02481830'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      opts={xml: xml, nct_id: nct_id}
      described_class.create_all_from(opts)

      inclusion = described_class.where(criterium_type: 'inclusion')
      exclusion = described_class.where(criterium_type: 'exclusion')
      other     = described_class.where(criterium_type: 'other')
      expect(inclusion.size).to eq(4)
      expect(exclusion.size).to eq(3)
      expect(other.size).to eq(1)
      sample = exclusion.select{|x| x.order_number == 3 }.first
      expect(sample.name).to eq("Inadequate hematologic or hepatic function")

      "For more information regarding BMS clinical trial participation, please visit www.BMSStudyConnect.com
      Inclusion Criteria:
      - Histologically or cytologically confirmed small cell lung cancer (SCLC)
      - Subjects with either limited or extensive disease stage at the initial diagnosis
      - Must have recurrence or progression after platinum-based first-line chemotherapy or chemoradiation therapy for the treatment of limited or extensive disease stage SCLC
      - Eastern Cooperative Oncology Group (ECOG) performance status 0 or 1
      Exclusion Criteria:
      - Untreated or symptomatic central nervous system (CNS) metastases
      - Prior therapy with anti-PD-1, anti-PDL1, anti-PD-L2, anti-CD137, or anti-CTLA-4 antibody
      - Inadequate hematologic or hepatic function"
    end
  end

end
