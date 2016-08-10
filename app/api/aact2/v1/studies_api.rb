module AACT2
  module V1
    class StudiesAPI < Grape::API
      desc '[GET] all studies' do
        detail <<-EOS
        <p>This endpoint is paginated with 500 records per page by default.</p>
        <p>Response Example:</p>
        <code>
        [
          {
            nct_id: "NCT00836407",
            first_received_date: "2009-02-03",
            verification_date: "2013-10-01",
            last_changed_date: "2013-10-16",
            primary_completion_date: "2012-07-01",
            completion_date: "2012-07-01",
            first_received_results_date: "2013-10-16",
            first_received_results_disposition_date: null,
            start_date_month_year: "February 2009",
            verification_date_month_year: "October 2013",
            primary_completion_date_month_day: "July 2012",
            completion_date_month_day: "July 2012",
            nlm_download_date_description: "ClinicalTrials.gov processed this data on June 19, 2016",
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
            start_date_month_day: "May 2007",
            verification_date_month_day: "December 2013",
            primary_completion_date_month_day: "March 2013",
            completion_date_month_day: "March 2013",
            nlm_download_date_description: "ClinicalTrials.gov processed this data on June 19, 2016",
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
        </code>
        EOS
        named 'Show a specific study'
        failure [
          [200, 'Success']
        ]
      end
      paginate per_page: 500
      get '/studies', root: false do
        paginate Study.all
      end

      desc '[GET] study by nct_id' do
        detail <<-EOS
          <p>Returns a single Study based on its nct_id.</p>
          <p>Example Response:</p>
          <code>
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
              start_date_month_day: "February 2009",
              verification_date_month_day: "October 2013",
              primary_completion_date_month_day: "July 2012",
              completion_date_month_day: "July 2012",
              nlm_download_date_description: "ClinicalTrials.gov processed this data on June 19, 2016",
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
          </code>
        EOS
        named 'Show a specific study'
        failure [
          [200, 'Success'],
          [404, 'Study Not Found']
        ]
      end
      params do
        requires :nct_id, type: String, desc: 'Study NCT ID'
        optional :with_related_records, type: Boolean, desc: 'return study with related records'
      end
      get '/studies/:nct_id' do
        study_req_params = declared(params, include_missing: false)
        @study = Study.find_by!(nct_id: study_req_params[:nct_id])
        if study_req_params[:with_related_records]
          @study.with_related_records = true
        end
        @study
      end

      desc '[GET] study counts by year' do
        detail <<-EOS
        <p>Example Response:</p>
        <code>
        {
          "1978": 1,
          "1983": 1,
          "1987": 1,
          "1988": 1,
          "1989": 2,
          "1990": 1,
          "1991": 2,
          "1993": 1,
          "1994": 1,
          "1995": 4,
          "1996": 6,
          "1997": 15,
          "1998": 22,
          "1999": 28,
          "2000": 31,
          "2001": 37,
          "2002": 42,
          "2003": 63,
          "2004": 81,
          "2005": 80,
          "2006": 121,
          "2007": 127,
          "2008": 135,
          "2009": 140,
          "2010": 122,
          "2011": 178,
          "2012": 159,
          "2013": 188,
          "2014": 213,
          "2015": 209,
          "2016": 137,
        }
        </code>
        EOS
        named 'Show study counts by year'
        failure [
          [200, 'Success']
        ]
      end
      get '/studies/counts/by_year', root: false do
        CalculatedValue.all.group('extract(year from start_date) :: integer').count
      end
    end
  end
end
