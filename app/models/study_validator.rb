class StudyValidator
  def initialize
    @errors = []
  end

  def validate_studies
    study1 = Study.find_by(nct_id: 'NCT00734539')
    study2 = Study.find_by(nct_id: 'NCT01076361')
    study3 = Study.find_by(nct_id: 'NCT01090362')
    study4 = Study.find_by(nct_id: 'NCT00660179')
    study5 = Study.find_by(nct_id: 'NCT02687217')
    study6 = Study.find_by(nct_id: 'NCT01983111')
    study7 = Study.find_by(nct_id: 'NCT02028676')

    assert(
      nct_id: study1.nct_id,
      validation_title: 'Outcome count',
      expected_result: 12,
      actual_result: study1.outcomes.count
    )

    assert(
      nct_id: study1.nct_id,
      validation_title: 'Brief title',
      expected_result: 'Fluconazole Prophylaxis for the Prevention of Candidiasis in Infants Less Than 750 Grams Birthweight',
      actual_result: study1.brief_title
    )

    assert(
      nct_id: study1.nct_id,
      validation_title: 'Study type',
      expected_result: 'Interventional',
      actual_result: study1.study_type
    )

    assert(
      nct_id: study1.nct_id,
      validation_title: 'Outcome Measured Value Dispersion Lower Limit',
      expected_result: 90.0,
      actual_result: study1.outcome_measures[9].dispersion_lower_limit
    )

    assert(
      nct_id: study1.nct_id,
      validation_title: 'Outcome Measured Value Dispersion Upper Limit',
      expected_result: 148.0,
      actual_result: study1.outcome_measures[9].dispersion_upper_limit
    )

    assert(
      nct_id: study2.nct_id,
      validation_title: 'Outcome count',
      expected_result: 1,
      actual_result: study2.outcomes.count
    )

    assert(
      nct_id: study2.nct_id,
      validation_title: 'Baseline measure count',
      expected_result: 13,
      actual_result: study2.baseline_measures.count
    )

    assert(
      nct_id: study2.nct_id,
      validation_title: 'Study type',
      expected_result: 'Observational [Patient Registry]',
      actual_result: study2.study_type
    )

    assert(
      nct_id: study3.nct_id,
      validation_title: 'Study type',
      expected_result: 'Observational',
      actual_result: study3.study_type
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Id Information Id Type',
      expected_result: 'org_study_id',
      actual_result: study4.id_information.id_type
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Id Information Id Value',
      expected_result: 'AC-055-302',
      actual_result: study4.id_information.id_value
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Study Brief Title',
      expected_result: 'Study of Macitentan (ACT-064992) on Morbidity and Mortality in Patients With Symptomatic Pulmonary Arterial Hypertension',
      actual_result: study4.brief_title
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Study Acronym',
      expected_result: 'SERAPHIN',
      actual_result: study4.acronym
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Study Official Title',
      expected_result: 'A Multicenter, Double-blind, Randomized, Placebo-controlled, Parallel Group, Event-driven, Phase III Study to Assess the Effects of Macitentan (ACT-064992) on Morbidity and Mortality in Patients With Symptomatic Pulmonary Arterial Hypertension',
      actual_result: study4.official_title
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Sponsor Lead or Collaborator',
      expected_result: 'lead',
      actual_result: study4.sponsors.first.lead_or_collaborator
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Sponsor Agency Class',
      expected_result: 'Industry',
      actual_result: study4.sponsors.first.agency_class
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Sponsor Name',
      expected_result: 'Actelion',
      actual_result: study4.sponsors.first.name
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Oversight Authority Name (First)',
      expected_result: 'China: Food and Drug Administration',
      actual_result: study4.oversight_authorities.first.name
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Brief Summary Description',
      expected_result: 'The AC-055-302/SERAPHIN study will be an event-driven Phase III study, comparing two different doses of macitentan (ACT-064992) (3 and 10 mg) vs placebo in patients with symptomatic PAH. The main study objective is to demonstrate that macitentan (ACT-064992) prolongs time to the first morbidity or mortality event, and to evaluate the benefit/risk profile of macitentan (ACT-064992) in the treatment of patients with symptomatic PAH.',
      actual_result: study4.brief_summary.description.gsub(/\s\s+/, ' ').gsub(/^\s+|\s+$/, '')
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Study Overall Status',
      expected_result: 'Completed',
      actual_result: study4.overall_status
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Study Start Month Year',
      expected_result: 'May 2008',
      actual_result: study4.start_month_year
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Study Completion Month Year',
      expected_result: 'April 2012',
      actual_result: study4.completion_month_year
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Study Primary Completion Month Year',
      expected_result: 'March 2012',
      actual_result: study4.primary_completion_month_year
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Study Phase',
      expected_result: 'Phase 3',
      actual_result: study4.phase
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Design Description (Primary Outcome)',
      expected_result: 'Allocation: Randomized, Endpoint Classification: Safety/Efficacy Study, Intervention Model: Parallel Assignment, Masking: Double Blind (Subject, Caregiver, Investigator, Outcomes Assessor), Primary Purpose: Treatment',
      actual_result: study4.design.description
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Design Outcome Measure (Primary Outcome)',
      expected_result: 'Time to First Confirmed Morbidity or Mortality Event up to the End of Treatment (Kaplan-Meier Estimate of Patients Without a Morbidity or Mortality Event)',
      actual_result: study4.design_outcomes.first.measure
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Design Outcome Time Frame (Primary Outcome)',
      expected_result: 'Up to end of treatment (data presented up to month 36)',
      actual_result: study4.design_outcomes.first.time_frame
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Design Outcome Safety Issue (Primary Outcome)',
      expected_result: 'No',
      actual_result: study4.design_outcomes.first.safety_issue
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Design Outcome Description (Primary Outcome)',
      expected_result: 'Morbidity or mortality events were defined as: a) Death; b) Atrial septostomy; c) Lung transplantation; d) Initiation of intravenous (i.v.) or subcutaneous prostanoids, or; e) Other worsening of pulmonary arterial hypertension (PAH). Other worsening of PAH was defined by the combined occurrence of all the following 3 events: At least 15% decrease in the 6 minute walk distance from baseline, confirmed by 2 tests performed on separate days, within 2 weeks. AND worsening of PAH symptoms including at least one of the following: a) Increase in WHO Functional Class (WHO FC), or no change in patients in WHO FC IV at baseline; b) Appearance or worsening of signs of right heart failure that did not respond to optimized oral diuretic therapy AND need for new treatment(s) for PAH that included the following: a) Oral or inhaled prostanoids; b) Oral phosphodiesterase inhibitors; c) Endothelin receptor antagonists (only after discontinuation of study treatment; d) i.v. diuretics',
      actual_result: study4.design_outcomes.first.description.gsub(/\n/," ")
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Design Outcome Measure (First Secondary Outcome)',
      expected_result: 'Time to Death Due to PAH or Hospitalisation for PAH up to the End of Treatment (Kaplan-Meier Estimate of Patients Without an Event)',
      actual_result: study4.design_outcomes.second.measure
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Design Outcome Time Frame (First Secondary Outcome)',
      expected_result: 'Up to end of treatment (data presented up to month 36)',
      actual_result: study4.design_outcomes.second.time_frame
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Design Outcome Safety Issue (First Secondary Outcome)',
      expected_result: 'No',
      actual_result: study4.design_outcomes.second.safety_issue
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Design Outcome Description (First Secondary Outcome)',
      expected_result: 'Events of PAH or hospitalization for PAH up to the end of treatment included: death due to PAH, or onset of a treatment-emergent adverse event with a fatal outcome due to PAH occurring up to 4 weeks after the end of treatment, or hospitalisation for PAH up to the end of treatment.',
      actual_result: study4.design_outcomes.second.description
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Study Number of Arms',
      expected_result: 3,
      actual_result: study4.number_of_arms
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Study Enrollment',
      expected_result: 742,
      actual_result: study4.enrollment
    )

    #TODO: figure out why this validation is getting an incorrect value ("Condition")
    # assert(
    #   nct_id: study4.nct_id,
    #   validation_title: 'Condition Name',
    #   expected_result: 'Pulmonary Arterial Hypertension',
    #   actual_result: study4.conditions.first.name
    # )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Design Group Title (First)',
      expected_result: '1',
      actual_result: study4.design_groups.first.title
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Design Group Group Type (First)',
      expected_result: 'Experimental',
      actual_result: study4.design_groups.first.group_type
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Design Group Description (First)',
      expected_result: 'Macitentan (ACT-064992) tablet, 3 mg, once daily',
      actual_result: study4.design_groups.first.description
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Intervention Intervention Type (First)',
      expected_result: 'Drug',
      actual_result: study4.interventions.first.intervention_type
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Intervention Name (First)',
      expected_result: 'macitentan (ACT-064992)',
      actual_result: study4.interventions.first.name
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Intervention Description (First)',
      expected_result: 'Tablet, 3 mg dosage, once daily',
      actual_result: study4.interventions.first.description
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Intervention Arm Group Label (First)',
      expected_result: '1',
      actual_result: study4.interventions.first.design_groups.first.title
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Intervention Intervention Type (Second)',
      expected_result: 'Drug',
      actual_result: study4.interventions.second.intervention_type
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Intervention Name (Second)',
      expected_result: 'macitentan (ACT-064992)',
      actual_result: study4.interventions.second.name
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Intervention Description (Second)',
      expected_result: 'Tablet, 10 mg dosage, once daily',
      actual_result: study4.interventions.second.description
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Intervention Arm Group Label (Second)',
      expected_result: '2',
      actual_result: study4.interventions.second.design_groups.first.title
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Intervention Intervention Type (Third)',
      expected_result: 'Drug',
      actual_result: study4.interventions.third.intervention_type
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Intervention Name (Third)',
      expected_result: 'placebo',
      actual_result: study4.interventions.third.name
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Intervention Description (Third)',
      expected_result: 'Matching placebo, once daily',
      actual_result: study4.interventions.third.description
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Intervention Arm Group Label (Third)',
      expected_result: '3',
      actual_result: study4.interventions.third.design_groups.first.title
    )

    #TODO: fix newline issue
    # assert(
    #   nct_id: study4.nct_id,
    #   validation_title: 'Eligibility Criteria',
    #   expected_result: 'Inclusion Criteria: 1. Signed informed consent prior to initiation of any study mandated procedure. 2. Patients with symptomatic pulmonary arterial hypertension (PAH) in modified World Health Organization (WHO) functional class II to IV. 3. Patients with the following types of pulmonary arterial hypertension (PAH) belonging to groups 1.1 to 1.3 of the Venice classification: - Idiopathic (IPAH); - Familial (FPAH); or - Related to: - Collagen vascular disease; - Simple, congenital systemic-to-pulmonary shunts at least 1 year post surgical repair; - Human immunodeficiency virus (HIV) infection; or - Drugs and toxins. 4. PAH diagnosis confirmed by hemodynamic evaluation performed prior to randomization and showing all of the following: - Mean pulmonary artery pressure (mPAP) > 25 mmHg at rest; - Pulmonary capillary wedge pressure (PCWP) or left ventricular end diastolic pressure (LVEDP) < 15 mmHg; and - Pulmonary vascular resistance (PVR) at rest >= 320 dyn×sec/cm^5. 5. 6-minute walk distance (6MWD) >= 50 m. 6. Men or women > 12 years of age (women of childbearing potential must have a negative pre-treatment serum pregnancy test and must use a reliable method of contraception). Exclusion Criteria: 1. PAH associated with portal hypertension, thyroid disorders, glycogen storage disease, Gaucher''s disease, hereditary hemorrhagic telangiectasia, hemoglobinopathies, myeloproliferative disorders or splenectomy. 2. PAH associated with non corrected simple congenital systemic-to-pulmonary shunts, and combined and complex systemic-to-pulmonary shunts, corrected or non corrected. 3. PAH associated with significant venous or capillary involvement (PCWP > 15 mmHg), known pulmonary veno-occlusive disease, and pulmonary capillary hemangiomatosis. 4. Persistent pulmonary hypertension of the newborn. 5. Pulmonary Hypertension belonging to groups 2 to 5 of the Venice classification. 6. Moderate to severe obstructive lung disease: forced expiratory volume in 1 second/forced vital capacity (FEV1/FVC) < 70% and FEV1 < 65% of predicted value after bronchodilator administration. 7. Moderate to severe restrictive lung disease: total lung capacity (TLC) < 60% of predicted value. 8. Moderate to severe hepatic impairment, i.e., Child-Pugh Class B or C. 9. Estimated creatinine clearance < 30 mL/min 10. Serum aspartate aminotransferase (AST) and/or alanine aminotransferase (ALT) > 1.5 times the upper limit of normal. 11. Hemoglobin < 75% of the lower limit of the normal range. 12. Systolic blood pressure < 100 mmHg. 13. Acute or chronic physical impairment (other than dyspnea), limiting the ability to comply with study requirements. 14. Pregnant or breast-feeding. 15. Known concomitant life-threatening disease with a life expectancy < 12 months. 16. Body weight < 40 kg. 17. Any condition that prevents compliance with the protocol or adherence to therapy. 18. Recently started (< 8 weeks prior to randomization) or planned cardio-pulmonary rehabilitation program based on exercise. 19. Treatment with endothelin receptor antagonists (ERAs) within 3 months prior to randomization. 20. Systemic treatment within 4 week prior to randomization with cyclosporine A or tacrolimus, everolimus, sirolimus (calcineurin or mammalian target of rapamycin (mTOR) inhibitors). 21. Treatment with cytochrome P3A (CYP3A) inducers within 4 weeks prior to randomization 22. Known hypersensitivity to drugs of the same class as the study drug, or any of their excipients. 23. Planned treatment, or treatment, with another investigational drug within 1 month prior to randomization.',
    #   actual_result: study4.eligibility.criteria.gsub(/\s\s+/, ' ').gsub(/^\s+|\s+$/, '')
    # )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Eligibility Gender',
      expected_result: 'Both',
      actual_result: study4.eligibility.gender
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Eligibility Minimum Age',
      expected_result: '12 Years',
      actual_result: study4.eligibility.minimum_age
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Eligibility Maximum Age',
      expected_result: 'N/A',
      actual_result: study4.eligibility.maximum_age
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Eligibility Healthy Volunteers',
      expected_result: 'No',
      actual_result: study4.eligibility.healthy_volunteers
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Overall Official Name',
      expected_result: 'Loic Perchenet, PhD',
      actual_result: study4.overall_officials.first.name
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Overall Official Role',
      expected_result: 'Study Chair',
      actual_result: study4.overall_officials.first.role
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Overall Official Affiliation',
      expected_result: 'Actelion',
      actual_result: study4.overall_officials.first.affiliation
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Facility Name',
      expected_result: 'University of Alabama at Birmingham',
      actual_result: study4.facilities.first.name
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Facility City',
      expected_result: 'Birmingham',
      actual_result: study4.facilities.first.city
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Facility State',
      expected_result: 'Alabama',
      actual_result: study4.facilities.first.state
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Facility Zip',
      expected_result: '35249-0001',
      actual_result: study4.facilities.first.zip
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Facility Country',
      expected_result: 'United States',
      actual_result: study4.facilities.first.country
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Country Name (Location)',
      expected_result: 'Argentina',
      actual_result: study4.countries.first.name
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Country Name (Removed)',
      expected_result: 'Portugal',
      actual_result: study4.countries.last.name
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Study Reference Citation',
      expected_result: 'Pulido T, Adzerikho I, Channick RN, Delcroix M, Galiè N, Ghofrani HA, Jansa P, Jing ZC, Le Brun FO, Mehta S, Mittelholzer CM, Perchenet L, Sastry BK, Sitbon O, Souza R, Torbicki A, Zeng X, Rubin LJ, Simonneau G; SERAPHIN Investigators. Macitentan and morbidity and mortality in pulmonary arterial hypertension. N Engl J Med. 2013 Aug 29;369(9):809-18. doi: 10.1056/NEJMoa1213917.',
      actual_result: study4.references.first.citation
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Study Reference PMID',
      expected_result: '23984728',
      actual_result: study4.references.first.pmid
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Study Verification Month Year',
      expected_result: 'August 2015',
      actual_result: study4.verification_month_year
    )

    # assert(
    #   nct_id: study4.nct_id,
    #   validation_title: 'Study Last Changed Date',
    #   expected_result: 2015-09-10,
    #   actual_result: study4.last_changed_date
    # )

    # assert(
    #   nct_id: study4.nct_id,
    #   validation_title: 'Study First Received Date',
    #   expected_result: 2008-04-14,
    #   actual_result: study4.first_received_date
    # )
    #
    # assert(
    #   nct_id: study4.nct_id,
    #   validation_title: 'Study First Received Results Disposition Date',
    #   expected_result: 2013-11-05,
    #   actual_result: study4.first_received_results_date
    # )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Responsible Party Type',
      expected_result: 'Sponsor',
      actual_result: study4.responsible_parties.first.responsible_party_type
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Keyword',
      expected_result: 'pulmonary arterial hypertension SERAPHIN',
      actual_result: study4.keywords.first.name
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Study Is FDA Regulated',
      expected_result: true,
      actual_result: study4.is_fda_regulated
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Study Is Section 801',
      expected_result: true,
      actual_result: study4.is_section_801
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Study Has Expanded Access',
      expected_result: false,
      actual_result: study4.has_expanded_access
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Browse Condition Mesh Term (First)',
      expected_result: 'Hypertension',
      actual_result: study4.browse_conditions.first.mesh_term
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Browse Condition Mesh Term (Second)',
      expected_result: 'Familial Primary Pulmonary Hypertension',
      actual_result: study4.browse_conditions.second.mesh_term
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Browse Intervention Mesh Term',
      expected_result: 'Macitentan',
      actual_result: study4.browse_interventions.first.mesh_term
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Participant Flow Recruitment Details',
      expected_result: 'A total of 955 patients were screened from 158 centers in 39 countries, and 742 patients from 151 centers in 39 countries were randomized',
      actual_result: study4.participant_flow.recruitment_details
    )

    #TODO: add validations for clinical_results/participant_flow/group_list

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Drop Withdrawal Period',
      expected_result: 'Overall Study',
      actual_result: study4.drop_withdrawals.first.period
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Milestone Title (Last)',
      expected_result: 'STARTED',
      actual_result: study4.milestones.last.title
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Milestone CTgov Group Code (Last)',
      expected_result: 'P1',
      actual_result: study4.milestones.last.ctgov_group_code
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Milestone Participant Count (Last)',
      expected_result: 250,
      actual_result: study4.milestones.last.participant_count
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Drop Withdrawal Reason (Last)',
      expected_result: 'Death',
      actual_result: study4.drop_withdrawals.last.reason
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Drop Withdrawal Ctgov Group Code (Last)',
      expected_result: 'P1',
      actual_result: study4.drop_withdrawals.last.ctgov_group_code
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Drop Withdrawal Count (Last)',
      expected_result: 44,
      actual_result: study4.drop_withdrawals.last.participant_count
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Baseline Measure Population',
      expected_result: 'For the baseline measures of age, gender, and World Health Organization (WHO) functional class, data were missing for 1 patient in the placebo group and for 2 patients in the 3 mg macitentan group.',
      actual_result: study4.baseline_measures.first.population
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Baseline Measure Ctgov Group Code',
      expected_result: 'B4',
      actual_result: study4.baseline_measures.first.ctgov_group_code
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Result Group Title (First)',
      expected_result: 'Total',
      actual_result: study4.result_groups.first.title
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Result Group Description (First)',
      expected_result: 'Total of all reporting groups',
      actual_result: study4.result_groups.first.description
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value Title',
      expected_result: 'Summary of the First Causes of Morbidity or Mortality',
      actual_result: study4.outcome_measures.first.title
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value Description',
      expected_result: 'Morbidity or mortality events were defined as: a) Death; b) Atrial septostomy; c) Lung transplantation; d) Initiation of intravenous (i.v.) or subcutaneous prostanoids, or; e) Other worsening of pulmonary arterial hypertension (PAH). Other worsening of PAH was defined by the combined occurrence of all the following 3 events: At least 15% decrease in the 6 minute walk distance from baseline, confirmed by 2 tests performed on separate days, within 2 weeks. AND worsening of PAH symptoms including at least one of the following: a) Increase in WHO Functional Class (WHO FC), or no change in patients in WHO FC IV at baseline; b) Appearance or worsening of signs of right heart failure that did not respond to optimized oral diuretic therapy AND need for new treatment(s) for PAH that included the following: a) Oral or inhaled prostanoids; b) Oral phosphodiesterase inhibitors; c) Endothelin receptor antagonists (only after discontinuation of study treatment; d) i.v. diuretics',
      actual_result: study4.outcome_measures.first.description.gsub(/\n/," ")
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value Units',
      expected_result: 'participants',
      actual_result: study4.outcome_measures.first.units
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value Param Type',
      expected_result: 'Number',
      actual_result: study4.outcome_measures.first.param_type
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value Category',
      expected_result: 'Lung transplantation',
      actual_result: study4.outcome_measures.first.category
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value CTgov Group Code',
      expected_result: 'O3',
      actual_result: study4.outcome_measures.first.ctgov_group_code
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value Param Value',
      expected_result: '0',
      actual_result: study4.outcome_measures.first.param_value
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value Title',
      expected_result: 'Number of Participants',
      actual_result: study4.outcome_measures.last.title
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value Units',
      expected_result: 'participants',
      actual_result: study4.outcome_measures.last.units
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value Param Type',
      expected_result: 'Number',
      actual_result: study4.outcome_measures.last.param_type
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value CTgov Group Code',
      expected_result: 'O1',
      actual_result: study4.outcome_measures.last.ctgov_group_code
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value Param Value',
      expected_result: '250',
      actual_result: study4.outcome_measures.last.param_value
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Type (Last)',
      expected_result: 'Primary',
      actual_result: study4.outcomes.last.outcome_type
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Title (Last)',
      expected_result: 'Time to First Confirmed Morbidity or Mortality Event up to the End of Treatment (Kaplan-Meier Estimate of Patients Without a Morbidity or Mortality Event)',
      actual_result: study4.outcomes.last.title
    )


    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Description (Last)',
      expected_result: 'Morbidity or mortality events were defined as: a) Death; b) Atrial septostomy; c) Lung transplantation; d) Initiation of intravenous (i.v.) or subcutaneous prostanoids, or; e) Other worsening of pulmonary arterial hypertension (PAH). Other worsening of PAH was defined by the combined occurrence of all the following 3 events: At least 15% decrease in the 6 minute walk distance from baseline, confirmed by 2 tests performed on separate days, within 2 weeks. AND worsening of PAH symptoms including at least one of the following: a) Increase in WHO Functional Class (WHO FC), or no change in patients in WHO FC IV at baseline; b) Appearance or worsening of signs of right heart failure that did not respond to optimized oral diuretic therapy AND need for new treatment(s) for PAH that included the following: a) Oral or inhaled prostanoids; b) Oral phosphodiesterase inhibitors; c) Endothelin receptor antagonists (only after discontinuation of study treatment; d) i.v. diuretics',
      actual_result: study4.outcomes.last.description.gsub(/\n/," ")
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Time Frame (Last)',
      expected_result: 'Up to end of treatment (data presented up to month 36)',
      actual_result: study4.outcomes.last.time_frame
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Safety Issue (Last)',
      expected_result: 'No',
      actual_result: study4.outcomes.last.safety_issue
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Population (Last)',
      expected_result: 'All randomized patients',
      actual_result: study4.outcomes.last.population
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Result Group Ctgov Group Code (Last)',
      expected_result: 'O1',
      actual_result: study4.outcomes.last.result_groups.last.ctgov_group_code
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Result Group Title (Last)',
      expected_result: 'Placebo',
      actual_result: study4.outcomes.last.result_groups.last.title
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Result Group Description (Last)',
      expected_result: 'Matching ACT-064992 placebo tablet, once daily',
      actual_result: study4.outcomes.last.result_groups.last.description
    )

    # assert(
    #   nct_id: study4.nct_id,
    #   validation_title: 'Baseline Measure Title',
    #   expected_result: 'Number of Participants',
    #   actual_result: study4.outcomes.last.baseline_measures.first.title
    # )

    #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis Count',
      expected_result: 8,
      actual_result: study4.outcome_analyses.count
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis Non Inferiority',
      expected_result: 'No',
      actual_result: study4.outcome_analyses.first.non_inferiority
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis P Value',
      expected_result: 0.2509,
      actual_result: study4.outcome_analyses.first.p_value
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis Method',
      expected_result: 'Log Rank',
      actual_result: study4.outcome_analyses.first.method
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis Param Type',
      expected_result: 'Hazard Ratio (HR)',
      actual_result: study4.outcome_analyses.first.param_type
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis Param Value',
      expected_result: 0.771,
      actual_result: study4.outcome_analyses.first.param_value
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis CI Percent',
      expected_result: 97.5,
      actual_result: study4.outcome_analyses.first.ci_percent
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis CI N Sides',
      expected_result: '2-Sided',
      actual_result: study4.outcome_analyses.first.ci_n_sides
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis CI Lower Limit',
      expected_result: 0.464,
      actual_result: study4.outcome_analyses.first.ci_lower_limit
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis CI Upper Limit',
      expected_result: 1.282,
      actual_result: study4.outcome_analyses.first.ci_upper_limit
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis Non Inferiority Last',
      expected_result: 'No',
      actual_result: study4.outcome_analyses.last.non_inferiority
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis P Value Last',
      expected_result: 0.0108,
      actual_result: study4.outcome_analyses.last.p_value
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis Method',
      expected_result: 'Log Rank',
      actual_result: study4.outcome_analyses.last.method
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis Param Type',
      expected_result: 'Hazard Ratio (HR)',
      actual_result: study4.outcome_analyses.last.param_type
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis Param Value',
      expected_result: 0.704,
      actual_result: study4.outcome_analyses.last.param_value
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis CI Percent',
      expected_result: 97.5,
      actual_result: study4.outcome_analyses.last.ci_percent
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis CI N Sides',
      expected_result: '2-Sided',
      actual_result: study4.outcome_analyses.last.ci_n_sides
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis CI Lower Limit',
      expected_result: 0.516,
      actual_result: study4.outcome_analyses.last.ci_lower_limit
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis CI Upper Limit',
      expected_result: 0.960,
      actual_result: study4.outcome_analyses.last.ci_upper_limit
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Reported Event Time Frame',
      expected_result: 'Up to end of treatment plus 28 days (Up to approximately 36 months)',
      actual_result: study4.reported_events.last.time_frame
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Reported Event Description',
      expected_result: 'One patient in the placebo group never received study treatment and was not included in the analysis. Adverse events during treatment period and up to 28 days after treatment discontinuation',
      actual_result: study4.reported_events.last.description
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Reported Event Ctgov Group Code',
      expected_result: 'E1',
      actual_result: study4.reported_events.last.ctgov_group_code
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Reported Event Default Vocab',
      expected_result: 'MedDRA 14.0',
      actual_result: study4.reported_events.last.default_vocab
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Reported Event Default Assessment',
      expected_result: 'Systematic Assessment',
      actual_result: study4.reported_events.last.default_assessment
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Reported Event Organ System',
      expected_result: 'Total',
      actual_result: study4.reported_events.last.organ_system
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Reported Event Ctgov Group Code',
      expected_result: 'E1',
      actual_result: study4.reported_events.last.ctgov_group_code
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Reported Event Subjects Affected',
      expected_result: 219,
      actual_result: study4.reported_events.last.subjects_affected
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Reported Event Subjects At Risk',
      expected_result: 249,
      actual_result: study4.reported_events.last.subjects_at_risk
    )

    assert(
      nct_id: study5.nct_id,
      validation_title: 'Outcome Measured Value Title',
      expected_result: 'Number of Participants',
      actual_result: study5.outcome_measures.last.title
    )

    assert(
      nct_id: study5.nct_id,
      validation_title: 'Outcome Measured Value Category',
      expected_result: 'Not required',
      actual_result: study5.outcome_measures.first.category
    )

    assert(
      nct_id: study5.nct_id,
      validation_title: 'Outcome Measured Value Title',
      expected_result: 'Number of Patients Requiring Additional Treatment',
      actual_result: study5.outcome_measures.first.title
    )

    assert(
      nct_id: study5.nct_id,
      validation_title: 'Outcome Measured Value Description',
      expected_result: 'Requirement of antipyretics; increased dose/ duration of antibiotic usage other than standard protocol; need for change to higher antibiotics; requirement of drainage procedures for pus/ wound infections; requirement for additional dressing sessions',
      actual_result: study5.outcome_measures.first.description
    )

    assert(
      nct_id: study5.nct_id,
      validation_title: 'Outcome Measured Value Units',
      expected_result: 'participants',
      actual_result: study5.outcome_measures.first.units
    )

    assert(
      nct_id: study5.nct_id,
      validation_title: 'Outcome Measured Value Ctgov Group Code',
      expected_result: 'O2',
      actual_result: study5.outcome_measures.first.ctgov_group_code
    )

    assert(
      nct_id: study5.nct_id,
      validation_title: 'Outcome Measured Value Param Type',
      expected_result: 'Number',
      actual_result: study5.outcome_measures.first.param_type
    )

    assert(
      nct_id: study5.nct_id,
      validation_title: 'Outcome Measured Value Param Value',
      expected_result: 30.0,
      actual_result: study5.outcome_measures.first.param_value_num
    )

    assert(
      nct_id: study5.nct_id,
      validation_title: 'Outcome Analysis Other P Value',
      expected_result: 0.5,
      actual_result: study5.outcome_analyses.first.p_value
    )

    assert(
      nct_id: study5.nct_id,
      validation_title: 'Outcome Analysis Method',
      expected_result: 'Chi-squared',
      actual_result: study5.outcome_analyses.first.method
    )

    assert(
      nct_id: study6.nct_id,
      validation_title: 'Outcome Analysis Non Inferiority Description',
      expected_result: 'In the PP set, for a non-inferiority test of the reduction in the pain intensity score from Visit 1 (Baseline) to Week 6 of treatment, the lower limit of the 97.5% onesided confidence interval was compared to a clinical non-inferiority margin, -1.5.',
      actual_result: study6.outcome_analyses.first.non_inferiority_description
    )

    assert(
      nct_id: study7.nct_id,
      validation_title: 'Outcome Analysis Method Description',
      expected_result: 'Generalised estimating equation with independent correlation structure and robust standard errors, calculated over all post-randomization visit weeks',
      actual_result: study7.outcome_analyses.first.method_description
    )

    assert(
      nct_id: study7.nct_id,
      validation_title: 'Outcome Analysis Estimate Description',
      expected_result: 'Hazard ratio is stop vs continue',
      actual_result: study7.outcome_analyses.second.estimate_description
    )

    assert(
      nct_id: study7.nct_id,
      validation_title: 'Reported Event Description',
      expected_result: 'Children were reviewed by a doctor at every scheduled doctor visit, as well as additional visits, and prompts on the doctor follow-up CRF asked about new/worsening/resolved Serious Adverse Events and Grade 3 or 4 Adverse Events.',
      actual_result: study7.reported_events.first.description
    )

    assert(
      nct_id: study7.nct_id,
      validation_title: 'Reported Event Time Frame',
      expected_result: 'LCM vs CDM and induction-maintenance: median 4 years (maximum 5 years); for randomizations; once vs twice daily: median 2 years (maximum 2.6 years); cotrimoxazole: median 2 years (maximum 2.5 years)',
      actual_result: study7.reported_events.first.time_frame
    )

    # assert(
    #   nct_id: study7.nct_id,
    #   validation_title: 'Reported Event Event Type',
    #   expected_result: '',
    #   actual_result:
    # )

    assert(
      nct_id: study7.nct_id,
      validation_title: 'Reported Event Default Vocab',
      expected_result: 'Trial-specific',
      actual_result: study7.reported_events.first.default_vocab
    )

    assert(
      nct_id: study7.nct_id,
      validation_title: 'Reported Event Default Assessment',
      expected_result: 'Systematic Assessment',
      actual_result: study7.reported_events.first.default_assessment
    )

    # assert(
    #   nct_id: study7.nct_id,
    #   validation_title: 'Reported Event Subjects Affected',
    #   expected_result: '',
    #   actual_result:
    # )

    # assert(
    #   nct_id: study7.nct_id,
    #   validation_title: 'Reported Event Subjects At Risk',
    #   expected_result: '',
    #   actual_result:
    # )

    # assert(
    #   nct_id: study7.nct_id,
    #   validation_title: 'Reported Event Event Count',
    #   expected_result: ,
    #   actual_result:
    # )

    # assert(
    #   nct_id: study7.nct_id,
    #   validation_title: 'Reported Event Ctgov Group Code',
    #   expected_result: ,
    #   actual_result:
    # )

    # assert(
    #   nct_id: study7.nct_id,
    #   validation_title: 'Reported Event Organ System',
    #   expected_result: 'Skin and subcutaneous tissue disorders',
    #   actual_result: study7.reported_events.first.category
    # )

    # assert(
    #   nct_id: study7.nct_id,
    #   validation_title: 'Reported Event Adverse Event Term',
    #   expected_result: '',
    #   actual_result:
    # )

    if @errors.present?
      StudyValidationMailer.send_alerts(@errors)

      raise StudyValidatorError
    else
      true
    end
  end

  class StudyValidatorError < StandardError
    def initialize(msg='Study validation failed')
      super
    end
  end

  private

  def assert(nct_id:, expected_result:, actual_result:, validation_title:)
    begin
      if actual_result != expected_result
      error = {
        nct_id: nct_id,
        validation_title: validation_title,
        expected_result: expected_result,
        actual_result: actual_result
      }

      @errors << error
      else
        true
      end
    rescue error => e
      puts 'you are here'
      print e
    end
  end
end
