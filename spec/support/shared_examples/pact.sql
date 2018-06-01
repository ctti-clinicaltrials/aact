--This script queries the CTGOV databases to provide a list of studies that determines if the study meets the PACT criteria and other information that can be used for various analysis

select cs.nct_id as "NCT ID",
       id.ID_value as "Sponsor Protocol ID",
       string_agg(distinct id1.ID_value, '|') as "All IDs",
       string_agg(distinct eu.EudraCT, '|') as "EudraCT #",
       cs.brief_title, cs.official_title,
       sp.name as "Lead Sponsor or PI", sp.agency_class as "Class",
       count (distinct (sp1.name)) as "Number of Collaborators",
       string_agg(distinct sp1.name || ' - '  || sp1.agency_class, ' | ') as "Collaborators",
       coalesce (NIH.NIH,'NO') as "NIH Funding",

       case
	       when NIH.NIH = 'YES' and cs.start_date >= '01-18-2017' then 'YES'
           when NIH.NIH = 'YES' and cs.primary_completion_date >= '01-18-2017' then 'YES'
           else 'NO'
       End as "NIH Policy",
       cs.overall_status as "Overall Recruiting Status", cs.why_stopped as "Why Stopped", cs.enrollment as "Enrollment",

      --these identify the conditions/indications being studied
       count(distinct (cond.id)) as "Number of Conditions",
       string_agg (distinct cond.name, ' | ') as "Conditions",
      --these are the fields that help identify pACT/ACT status
      cs.study_type as "Study Type", cs.phase as "Phase", des.primary_purpose as "Primary Purpose" ,cs.is_fda_regulated_drug as "Is FDA Regulated Drug",
      cs.is_fda_regulated_device as "Is FDA Regulated Device", cs.is_ppsd as "Pediatric Postmarket Surveillence - Device",

      --These identify the interventions
      count (intx.id) as "Number of Interventions",
      string_agg(distinct intx.intervention_type, ' | ') as "Intervention Types",
      string_agg(distinct intx.name, ' | ') as "Intervention Names",
      string_agg (distinct intz.name, ' | ') as "Other Intervention Names",
      coalesce (song.app_int,'NO') as "Applicable Intervention",
      cs.is_us_export as "Exported from US",

      --studies with US Locations
      coalesce (USLOC.US_Loc,'NO') as "US Site",

      --studies with EU Locations
      coalesce (EULOC.EU_Loc,'NO') as "EU Site",

      --studies with ex US or EU Locations
      coalesce (EXUSEU.ex_US_EU,'NO') as "EX US or EU Site",

      count (distinct (locx.name)) as "Number of Distinct Countries",
      string_agg(distinct locx.name, ' | ') as "Countries",

      --This indicates if the study has protocol or results applicable to FDAAA or Final Rule
      case
	      when ppact.ppact = 'YES' then 'FDAAA'
        when ProtAct.p_act = 'YES' then 'Final Rule'
        else 'Not Required*'
      End as "Protocol",

      case
	      when ppact.ppact = 'YES' and cs.primary_completion_date < '01-18-2017' then 'FDAAA'
        when ppact.ppact = 'YES' and cs.primary_completion_date >= '01-18-2017' then 'Final Rule'
        when ProtAct.p_act = 'YES' then 'Final Rule'
        else 'Not Required*'
      End as "Results",

--Protocol Registration Information
cs.start_date as "Start Date", (date_trunc('MONTH', cs.start_date) + INTERVAL '1 MONTH - 1 day')::date as "Start EOM",
f.regdue as "Registration Due",
cs.first_received_date as "Registration First Recd",
	case
		When cs.start_date is null then 'No Start Date Provided'
    	When cs.first_received_date <= f.regdue then 'On Time'
    	Else 'Late'
   		end as "Registration Timeliness",


--Results Disclosure Information
cs.primary_completion_date as "Primary Completion Date", cs.primary_completion_date_type as "PCD Type",(date_trunc('MONTH', cs.primary_completion_date) + INTERVAL '1 MONTH - 1 day')::date as "PCD EOM",
cs.completion_date as "Study Completion Date", cs.completion_date_type as "SCD Type",(date_trunc('MONTH', cs.completion_date) + INTERVAL '1 MONTH - 1 day')::date as "SCD EOM",
g.resultsdue as "Results Due",
cs.first_received_results_date as "Results First Recd",
cs.received_results_disposit_date as "Delay Request Recd",

case
when g.resultsdue is null then 'Cannot Determine Due Date'
when cs.first_received_results_date <= g.resultsdue then 'Posted On-Time'
when cs.first_received_results_date > g.resultsdue then 'Posted Late'
when (((cs.first_received_results_date is null and cs.received_results_disposit_date is null) or (cs.first_received_results_date is null and cs.received_results_disposit_date is not null)) and g.resultsdue < now () - interval '90 days') then 'Missing'
when (cs.first_received_results_date is null and g.resultsdue > now () - interval '90 days') then 'Results Due in the Future'
else 'Verify'
end as "Results Timeliness",

case
	when cs.first_received_results_date is null then 'Missing Results'
    else 'Results Present'
    end as "Results Availablility",

cs.nlm_download_date_description as "CTGOV Download Desc", cs.last_changed_date, cs.verification_date

from studies as cs
left join sponsors       as sp    on cs.nct_id=sp.nct_id
left join sponsors       as sp1   on cs.nct_id=sp1.nct_id
left join conditions     as cond  on cs.nct_id=cond.nct_id
left join interventions  as intx  on cs.nct_id=intx.nct_id
left join intervention_other_names as intz on intx.id=intz.intervention_id
left join countries      as locx  on cs.nct_id=locx.nct_id
left join id_information as ID    on cs.nct_id=id.nct_id
left join id_information as ID1   on cs.nct_id=id1.nct_id
left join designs        as des   on cs.nct_id=des.nct_id

--This join identifies if the study includes an applicable intervention type
left join (select distinct int1.nct_id, 'YES' as app_int
	from interventions as int1
	where int1.intervention_type in ('Drug', 'Biological', 'Device', 'Radiation', 'Genetic','Combination Product','Diagnostic Test'))
    as song on cs.nct_id=song.nct_id

--This join identified is the study has a location in the US or US Territory
left join (select distinct loc1.nct_id, 'YES' as US_Loc
	from countries as loc1
	where loc1.name in ('United States', 'American Samoa', 'Guam', 'Northern Mariana Islands', 'Puerto Rico', 'U.S. Virgin Islands')
    		)
    as USLOC on cs.nct_id = USLOC.nct_id

--This join identifies if the study has an EU location
left join (select distinct loc2.nct_id, 'YES' as EU_Loc
	from countries as loc2
	where loc2.name in ('Austria', 'Belgium', 'Bulgaria', 'Croatia', 'Cyprus', 'Czech Republic', 'Denmark', 'Estonia', 'Finland', 'France', 'Germany', 'Greece', 'Hungary', 'Ireland', 'Italy', 'Latvia', 'Lithuania', 'Luxembourg', 'Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania', 'Slovakia', 'Slovenia', 'Spain', 'Sweden', 'United Kingdom'))
    as EULOC on cs.nct_id = EULOC.nct_id

--This join identifies if the study has an ex-US or ex_EU location
left join (select distinct loc3.nct_id, 'YES' as ex_US_EU
	from countries as loc3
	where loc3.name not in ('United States', 'American Samoa', 'Guam', 'Northern Mariana Islands', 'Puerto Rico', 'U.S. Virgin Islands', 'Austria', 'Belgium', 'Bulgaria', 'Croatia', 'Cyprus', 'Czech Republic', 'Denmark', 'Estonia', 'Finland', 'France', 'Germany', 'Greece', 'Hungary', 'Ireland', 'Italy', 'Latvia', 'Lithuania', 'Luxembourg', 'Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania', 'Slovakia', 'Slovenia', 'Spain', 'Sweden', 'United Kingdom'))
    as EXUSEU on cs.nct_id = EXUSEU.nct_id

--These joins identify the due dates for registration or results
left join  (select nct_id,
    		case
               --When cs3.start_date is null then '1900-01-01'
                when cs3.start_date <= '2007-09-27' then '2008-09-27'
            	when cs3.start_date <= '2017-01-18' and extract(day from cs3.start_date)=1 then (date_trunc('MONTH', cs3.start_date) + INTERVAL '1 MONTH + 20 days')::date
                else (cs3.start_date + interval '21 days')::date
                end as regdue
            from studies as cs3) as f on cs.nct_id=f.nct_id

left join  (select nct_id,
			case
				When cs4.received_results_disposit_date is not null then (cs4.received_results_disposit_date + interval '24 months')::date
   				--When cs4.primary_completion_date is null and cs4.completion_date is null then '1900-01-01'
    			When cs4.primary_completion_date is null and cs4.completion_date is not null then (cs4.completion_date + interval '12 months')::date
     			When cs4.primary_completion_date is not null and cs4.primary_completion_date <= '2017-01-18' and extract(day from cs4.primary_completion_date)=1
            		then(date_trunc('MONTH', cs4.primary_completion_date) + INTERVAL '13 MONTHS - 1 day')::date
             	else (cs4.primary_completion_date + interval '12 months')::date
    			end as resultsdue
            from studies as cs4) as g on cs.nct_id=g.nct_id


--This join identifies EudraCT ID (if it the ID matches the pattern)
left join (select distinct eu1.nct_id, id_value as EudraCT
           from id_information as eu1
           where eu1.id_type = 'secondary_id'
           and eu1.id_value like '%20__-______-__%')
           as eu on cs.nct_id=eu.nct_id


--This join identifies if the protocol is a pACT (applicable to FDAAA)
left join (select distinct cs1.nct_id, 'YES' as PPACT
			from studies as cs1
				left join countries as locx1 on cs1.nct_id=locx1.nct_id
         		left join (select distinct int2.nct_id, 'YES' as app_int1
					from interventions as int2
					where int2.intervention_type in ('Drug', 'Biological', 'Device', 'Radiation', 'Genetic', 'Combination Product', 'Diagnostic Test')
					) as intervention2 on cs1.nct_id=intervention2.nct_id
				left join (select distinct loc2.nct_id, 'YES' as US_Loc2
					from countries as loc2
					where loc2.name in ('United States', 'American Samoa', 'Guam', 'Northern Mariana Islands', 'Puerto Rico', 'U.S. Virgin Islands')
					) as act2 on cs1.nct_id = act2.nct_id
			where cs1.study_type = 'Interventional'
			and cs1.phase not in ('Early Phase 1', 'Phase 1')
			and cs1.overall_status != 'Withdrawn'
			and intervention2.app_int1='YES'
			and ((cs1.start_date >'09-27-2007' and cs1.start_date < '01-18-2017')
    				or (cs1.start_date <= '9-27-2007' and cs1.primary_completion_date >= '12-26-2007')
					or (cs1.start_date <= '9-27-2007' and cs1.primary_completion_date is null and cs1.completion_date >= '12/26/2007'))
          	and ((us_loc2 = 'YES' or locx1.name is null) or (cs1.is_fda_regulated_drug = 'TRUE' or cs1.is_fda_regulated_device = 'TRUE'))
          	) as PPACT on cs.nct_id = ppact.nct_id

--This join identifies if the protocol is a ACT (applicable to Final Rule)
left join (select distinct cs2.nct_id, 'YES' as P_ACT
			from studies as cs2
				left join countries as locx2 on cs2.nct_id=locx2.nct_id
                left join designs as des1 on cs2.nct_id=des1.nct_id
         		left join (select distinct loc3.nct_id, 'YES' as US_Loc3
					from countries as loc3
					where loc3.name in ('United States', 'American Samoa', 'Guam', 'Northern Mariana Islands', 'Puerto Rico', 'U.S. Virgin Islands')
					) as act3 on cs2.nct_id = act3.nct_id
			where cs2.start_date >= '01/18/2017'
            and cs2.study_type = 'Interventional'
            and (cs2.is_fda_regulated_drug = 'TRUE' or cs2.is_fda_regulated_device = 'TRUE')
            and (cs2.phase not in ('Early Phase 1', 'Phase 1') and des1.primary_purpose != 'Device Feasibility')
            /* commenting out this clause because in the checklist for evaluating if a trial is an ACT, there are 4 question which all must answer yes to be an ACT.
            ** Question #2 has 3 parts, one of which is if the study is conducted under an IND/IDE.  This information is not public.  However, Question #4 is if the
            ** trial studies an FDA regulated drug or device.  One of the quirks of the law is that you cannot answer these as 'YES' unless IND/IDE is 'Yes', so defacto,
            ** the location and export status are irrelevant becase IND/IDE must be yes if FDA regulated is yes.
           and (us_loc3 = 'YES' or cs2.is_us_export = 'TRUE') */
          	) as ProtAct on cs.nct_id = ProtAct.nct_id

--This join identifies if the collaborator is NIH
left join (select distinct sp2.nct_id, 'YES' as NIH
           from sponsors as sp2
           where sp2.lead_or_collaborator = 'collaborator'
           and sp2.name in (
               'Adaptive Sensory Technology; National Eye Institute',
				'Eunice Kennedy Shriver National Institute of Child Health and Human Development (NICHD)',
				'Federal, State foundation and industry support: National Institute of Health (NIH), Muscular Dystrophy Association, Charcot Marie Tooth Association',
				'Fogarty AIDS international training research program',
				'Fogarty International Clinical Research Scholarship',
				'Foundation for the National Institutes of Health',
				'General Clinical Research Center (NIH)',
				'Infrared Imaging and Thermometry Unit, Biomedical Engineering and Physical Science Shared Resource (NIBIB)',
				'John E. Fogarty International Center (FIC)',
				'National Cancer Institute (NCI)',
				'National Cancer Institute (NCI), Naples',
				'National Cancer Institute, Naples',
				'National Center for Advancing Translational Science (NCATS)',
				'National Center for Complementary and Integrative Health (NCCIH)',
				'National Eye Institute (NEI)',
				'National Heart, Lung, and Blood Institute (NHLBI)',
				'National Human Genome Research Institute (NHGRI)',
				'National Institute for Biomedical Imaging and Bioengineering (NIBIB)',
				'National Institute of Allergy and Infectious Diseases (NIAID)',
				'The National Institute of Allergy and Infectious Diseases, United States',
				'US National Institute of Allergy and Infectious Diseases',
				'National Institute of Allergy and Infectious Diseases@@@Coley Pharmaceutical Group',
				'National Institute of Arthritis and Musculoskeletal and Skin Diseases (NIAMS)',
				'National Institute of Dental and Craniofacial Research (NIDCR)',
				'National Institute of Diabetes and Digestive and Kidney Diseases (NIDDK)',
				'National Institute of Environmental Health Sciences (NIEHS)',
				'National Institute of General Medical Sciences (NIGMS)',
				'National Institute of Mental Health (NIMH)',
				'National Institute of Mental Health, Eli Lilly & Co.',
				'National Institute of Neurological Disorders and Stroke (NINDS)',
				'National Institute of Neurological Disorders and Stroke@@@Shire Human Genetic Therapies (HGT)',
				'National Institute of Nursing Research (NINR)',
				'National Institute on Aging (NIA)',
				'National Institute on Alcohol Abuse and Alcoholism (NIAAA)',
				'National Institute on Deafness and Other Communication Disorders (NIDCD)',
				'National Institute on Drug Abuse (NIDA)',
				'National Institute on Drug Abuse (NIDA) (DA038095)',
				'National Institute on Minority Health and Health Disparities (NIMHD)',
				'National Institutes of Health - Intramural Branch (Bethesda)',
				'National Institutes of Health (NIH)',
				'National Institutes of Health (NIH)Pakistan',
				'National Institutes of Health Clinical Center (CC)',
				'National Institutes of Health Common Fund',
				'National Institutes of Health, Fogarty International Center',
				'National Library of Medicine (NLM)',
				'NIAID Vaccine and Treatment Evaluation Units (VTEUs)',
				'NICHD Global Network for Women''s and Children''s Health',
				'NICHD Neonatal Research Network',
				'NICHD Pelvic Floor Disorders Network',
				'NIH Biomarker, Imaging and Quality of Life Studies Funding Program (BIQSFP)',
				'NIH Common Fund',
				'NIH Fogarty International Center',
				'NIH Heart Center at Suburban Hospital',
				'NIH K01 Career Development Award',
				'NIH Office of AIDS Research (OAR)',
				'NIH T32 Human and Molecular Development Training Grant',
				'NINDS Stroke Trials Network (StrokeNet)',
				'United States Department of Health and Human Services, Center for Disease Control and Prevention, National Institutes of Health, Department of Defense',
				'US National Institute of Child Health and Human Development',
				'US NIH Research Project Grant Program')
           ) as NIH on cs.nct_id = NIH.nct_id

where id.id_type = 'org_study_id'
  and sp.lead_or_collaborator = 'lead'
  and sp.agency_class = 'Industry'

group by cs.nct_id, id.id_value, cs.brief_title, nih.nih,
    ppact.ppact, ProtAct.p_act, regdue, resultsdue,
    cs.overall_status, cs.last_known_status, cs.official_title,sp.name, cs.is_us_export,
    sp.lead_or_collaborator, sp.agency_class, cs.brief_title, cs.study_type, cs.why_stopped, cs.enrollment, cs.phase, cs.is_ppsd,
    des.primary_purpose,
    cs.start_date,cs.primary_completion_date, cs.primary_completion_date_type,
    cs.completion_date_type, cs.completion_date,
    cs.is_fda_regulated_drug, cs.is_fda_regulated_device,
    cs.first_received_date,
    cs.first_received_results_date,
    cs.received_results_disposit_date,
    song.app_int, usloc.us_loc, euloc.eu_loc, EXUSEU.ex_US_EU,cs.nlm_download_date_description, cs.last_changed_date, cs.verification_date

order by cs.nct_id asc