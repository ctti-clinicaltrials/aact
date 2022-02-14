module Node
  class StatusModule < Node::Base
    attr_accessor :study_first_submit_date, :results_first_submit_date, :disp_first_submit_date,
                  :last_update_submit_date, :study_first_submit_qc_date, :results_first_submit_qc_date,
                  :disp_first_submit_qc_date, :status_verified_date, :overall_status, :last_known_status,
                  :why_stopped
                  
    attr_accessor :study_first_post_date_struct, :results_first_post_date_struct, :disp_first_post_date_struct,
                  :last_update_post_date_struct, :start_date_struct, :completion_date_struct,
                  :primary_completion_date_struct, :expanded_access_info

    def process(root)
      root.study.study_first_submitted_date = get_date(study_first_submit_date)
      root.study.results_first_submitted_date = get_date(results_first_submit_date)
      root.study.disposition_first_submitted_date = get_date(disp_first_submit_date)
      root.study.last_update_submitted_date = get_date(last_update_submit_date)
      root.study.study_first_submitted_qc_date = get_date(study_first_submit_qc_date)
      root.study.results_first_submitted_qc_date = get_date(results_first_submit_qc_date)
      root.study.disposition_first_submitted_qc_date = get_date(disp_first_submit_qc_date)
      root.study.verification_month_year = status_verified_date
      root.study.verification_date = convert_date(status_verified_date)
      root.study.overall_status = overall_status
      root.study.last_known_status = last_known_status
      root.study.why_stopped = why_stopped

      study_first_post_date_struct.process(root) if study_first_post_date_struct
      results_first_post_date_struct.process(root) if results_first_post_date_struct
      disp_first_post_date_struct.process(root) if disp_first_post_date_struct
      last_update_post_date_struct.process(root) if last_update_post_date_struct
      start_date_struct.process(root) if start_date_struct
      completion_date_struct.process(root) if completion_date_struct
      primary_completion_date_struct.process(root) if primary_completion_date_struct
      expanded_access_info.process(root) if expanded_access_info
    end
  end
end