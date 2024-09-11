module CTGov
class StudySyncService

  # def initialize(api_client = API::CTGovClientV2.new)
  def initialize(api_client = CTGov::ApiClient::V2.new)
    unless api_client.is_a?(CTGov::ApiClient::Base)
      raise ArgumentError, "Invalid API client. Must inherit from CTGov::ApiClient::Base"
    end
    @api_client = api_client
  end

  def sync_recent_studies_from_api
    start_date = get_sync_start_date
    @api_client.get_studies_in_date_range(start_date: start_date, page_size: 500) do |studies|
      persist(studies)
    end
  end

  def refresh_studies_from_db
    list = Study.order(updated_at: :asc).limit(500).pluck(:nct_id)
    raise "No Studies found to sync" if list.empty?
    @api_client.get_studies_by_nct_ids(list: list, page_size: 500) do |studies|
      persist(studies)

      # removing study logic
      api_nct_ids = studies.map { |study| study.dig(*@api_client.nct_id_path) }
      missing_nct_ids = list - api_nct_ids
      remove_studies(missing_nct_ids) if missing_nct_ids.present?
    end
  end

  private

  def remove_studies(nct_ids)
    Rails.logger.info("Removing #{nct_ids} studies from the database")
    StudyJsonRecord.where(nct_id: nct_ids, version: @api_client.version).delete_all
    # remove study and related records
    nct_ids.each do |nct_id|
      StudyRelationship.study_models.each do |model|
        model.where(nct_id: nct_id).delete_all
      end
      Rails.logger.info("Removed #{nct_id} from all related tables")
    end
  end

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

  # TODO: possibly move to SJR model
  def build_study_record(study_json)
    StudyJsonRecord.new(
      nct_id: study_json.dig(*@api_client.nct_id_path),
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
      Date.today - 5 # TODO: review this default
    end
  end
end
end