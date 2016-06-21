module StudiesDoc
  extend BaseDoc

  resource_description do
    resource_id 'Studies'
  end

  api :GET, '/studies/:nct_id', 'Show a specific study'
  param :nct_id, String, required: true
  example <<-EOS
    {
      study: {
        nct_id: "NCT00836407",
        start_date: "2009-02-01",
        first_received_date: "2009-02-03",
        verification_date: "2013-10-01",
        last_changed_date: "2013-10-16",
        primary_completion_date: "2012-07-01",
        completion_date: "2012-07-01",
        first_received_results_date: "2013-10-16",
        download_date: null,
        start_date_str: "February 2009",
        first_received_date_str: "February 3, 2009",
        verification_date_str: "October 2013",
        last_changed_date_str: "October 16, 2013",
        primary_completion_date_str: "July 2012",
        completion_date_str: "July 2012",
        first_received_results_date_str: "October 16, 2013",
        download_date_str: "ClinicalTrials.gov processed this data on June 19, 2016",
        completion_date_type: "Actual",
        primary_completion_date_type: "Actual",
        org_study_id: "J0834",
        secondary_id: null,
        study_type: "Interventional",
        overall_status: "Completed",
        phase: "Phase 1",
        target_duration: "",
        enrollment: 30,
        enrollment_type: "Actual",
        source: "",
        biospec_retention: "",
        limitations_and_caveats: "",
        delivery_mechanism: null,
        description: null,
        acronym: "",
        number_of_arms: 2,
        number_of_groups: null,
        why_stopped: "",
        has_expanded_access: false,
        has_dmc: true,
        is_section_801: true,
        is_fda_regulated: true,
        brief_title: "Ipilimumab +/- Vaccine Therapy in Treating Patients With Locally Advanced, Unresectable or Metastatic Pancreatic Cancer",
        official_title: "A Phase Ib Trial Evaluating the Safety and Feasibility of Ipilimumab (BMS-734016) Alone or in Combination With Allogeneic Pancreatic Tumor Cells Transfected With a GM-CSF Gene for the Treatment of Locally Advanced, Unresectable or Metastatic Pancreatic Adenocarcinoma",
        biospec_description: "",
        created_at: "2016-06-20T21:32:48Z",
        updated_at: "2016-06-20T21:32:48Z"
      }
    }
  EOS
  def show
  end

  api :GET, '/studies', 'Show all studies'
  description 'For now, this endpoint is not rate limited or paged, so it will return all studies in one request. This will be slow by default because it is sending a ton of data over the wire. Best practice is to use pagination, which we will add after further discussion.'
  example <<-EOS
  [
    {
      nct_id: "NCT00836407",
      start_date: "2009-02-01",
      first_received_date: "2009-02-03",
      verification_date: "2013-10-01",
      last_changed_date: "2013-10-16",
      primary_completion_date: "2012-07-01",
      completion_date: "2012-07-01",
      first_received_results_date: "2013-10-16",
      download_date: null,
      start_date_str: "February 2009",
      first_received_date_str: "February 3, 2009",
      verification_date_str: "October 2013",
      last_changed_date_str: "October 16, 2013",
      primary_completion_date_str: "July 2012",
      completion_date_str: "July 2012",
      first_received_results_date_str: "October 16, 2013",
      download_date_str: "ClinicalTrials.gov processed this data on June 19, 2016",
      completion_date_type: "Actual",
      primary_completion_date_type: "Actual",
      org_study_id: "J0834",
      secondary_id: null,
      study_type: "Interventional",
      overall_status: "Completed",
      phase: "Phase 1",
      target_duration: "",
      enrollment: 30,
      enrollment_type: "Actual",
      source: "",
      biospec_retention: "",
      limitations_and_caveats: "",
      delivery_mechanism: null,
      description: null,
      acronym: "",
      number_of_arms: 2,
      number_of_groups: null,
      why_stopped: "",
      has_expanded_access: false,
      has_dmc: true,
      is_section_801: true,
      is_fda_regulated: true,
      brief_title: "Ipilimumab +/- Vaccine Therapy in Treating Patients With Locally Advanced, Unresectable or Metastatic Pancreatic Cancer",
      official_title: "A Phase Ib Trial Evaluating the Safety and Feasibility of Ipilimumab (BMS-734016) Alone or in Combination With Allogeneic Pancreatic Tumor Cells Transfected With a GM-CSF Gene for the Treatment of Locally Advanced, Unresectable or Metastatic Pancreatic Adenocarcinoma",
      biospec_description: "",
      created_at: "2016-06-20T21:32:48Z",
      updated_at: "2016-06-20T21:32:48Z"
    },
    {
      nct_id: "NCT00900003",
      start_date: "2007-05-01",
      first_received_date: "2009-05-09",
      verification_date: "2013-12-01",
      last_changed_date: "2013-12-10",
      primary_completion_date: "2013-03-01",
      completion_date: "2013-03-01",
      first_received_results_date: null,
      download_date: null,
      start_date_str: "May 2007",
      first_received_date_str: "May 9, 2009",
      verification_date_str: "December 2013",
      last_changed_date_str: "December 10, 2013",
      primary_completion_date_str: "March 2013",
      completion_date_str: "March 2013",
      first_received_results_date_str: "",
      download_date_str: "ClinicalTrials.gov processed this data on June 19, 2016",
      completion_date_type: "Actual",
      primary_completion_date_type: "Actual",
      org_study_id: "VICC GI 0717",
      secondary_id: null,
      study_type: "Observational",
      overall_status: "Completed",
      phase: "N/A",
      target_duration: "",
      enrollment: 53,
      enrollment_type: "Actual",
      source: "",
      biospec_retention: "",
      limitations_and_caveats: "",
      delivery_mechanism: null,
      description: null,
      acronym: "",
      number_of_arms: null,
      number_of_groups: 1,
      why_stopped: "",
      has_expanded_access: false,
      has_dmc: false,
      is_section_801: null,
      is_fda_regulated: false,
      brief_title: "Studying Biomarkers in Patients With Pancreatic Cancer",
      official_title: "Developing Biomarkers in Pancreatic Cancer",
      biospec_description: "",
      created_at: "2016-06-20T21:32:49Z",
      updated_at: "2016-06-20T21:32:49Z"
    },
    ...
  ]
  EOS
  def index
  end

end
