class StudySyncService

  def initialize(api_client = API::CTGovClientV2.new)
    unless api_client.is_a?(API::CTGovClientInterface)
      raise ArgumentError, "Invalid API client. Must implement API::CTGovClientInterface"
    end
    @api_client = api_client
  end

  def sync_recent_studies_from_api
    # start_date = get_sync_start_date
    start_date = "2024-09-03"
    @api_client.get_studies_in_date_range(start_date: start_date, page_size: 500) do |studies|
      persist(studies)
    end
  end

  def refresh_studies_from_db
    list = Study.order(updated_at: :asc).limit(500).pluck(:nct_id)
    raise "No Studies found to sync" if list.empty?
    @api_client.get_studies_by_nct_ids(list: list, page_size: 500) do |studies|
      persist(studies)
    end
  end

  private

  def persist(studies)
    silence_active_record do
      study_records = studies.map do |study_json|
        build_study_record(study_json)
      end.compact # Remove nil records where nct_id was missing

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

  def build_study_record(study_json)
    nct_id = study_json.dig("protocolSection", "identificationModule", "nctId")

    if nct_id.nil?
      Rails.logger.warn("NCT ID can't be found in #{study_json}")
      return nil
    end

    StudyJsonRecord.new(
      nct_id: nct_id,
      version: @api_client.version,
      content: study_json,
      download_date: Date.today.to_s
    )
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