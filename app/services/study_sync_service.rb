class StudySyncService
  # get recently updated studies (compared to last aact udpate)
  # get studies that has been removed, merged by ctgov
  # have a comparison logic to define studies needs to be updated
  # new studies?

  def initialize(api_client = API::CTGovClientV2.new)
    @api_client = api_client
  end

  def sync_recent_studies
    # start_date = get_sync_start_date
    start_date = "2024-09-03"
    @api_client.get_studies_in_date_range(start_date: start_date, page_size: 500) do |studies|
      persist(studies)
    end
  end

  private

  def persist(studies)
    silence_active_record do
      study_records = studies.map do |study_json|
        nct_id = study_json["protocolSection"]["identificationModule"]["nctId"]
        StudyJsonRecord.new(
          nct_id: nct_id,
          version: "2",
          content: study_json,
          download_date: Date.today.to_s,
        )
      end

      StudyJsonRecord.import(
        study_records,
        on_duplicate_key_update: {
          conflict_target: [:nct_id, :version],
          columns: [:content, :download_date, :updated_at]
        }
      )

      Rails.logger.info("Imported #{study_records.size} StudyJsonRecords")
    end
  end

  def get_sync_start_date
    last_event = Support::LoadEvent
                  .where(event_type: 'incremental', status: 'complete')
                  .order(completed_at: :desc)
                  .first

    if last_event && last_event.completed_at
      # TODO: figure out the timezone, so we don't have to reprocess a day ago
      last_event.completed_at.to_date - 1
    else
      Rails.logger.warn("No complete incremental events found, using default start date.")
      Date.today - 5 # or any default date you want to use
    end
  end
end