class StudySyncService
  # get recently updated studies (compared to last aact udpate)
  # get studies that has been removed, merged by ctgov
  # have a comparison logic to define studies needs to be updated
  # new studies?

  def initialize(api_client = API::CTGovClientV2.new)
    @api_client = api_client
  end

  # get a better name - for now mimic study_downloader
  def download_recently_updated
    start_date = fetch_start_date
    studies = @api_client.fetch_studies_by_date(start_date: start_date)
    studies.each do |study_json|
      nct_id = study_json["protocolSection"]["identificationModule"]["nctId"]
      # byebug if nct_id == "NCT06211660"
      json_record = StudyJsonRecord.find_or_create_by(nct_id: nct_id, version: '2') { |r| r.content = {} }
      json_record.update(content: study_json, download_date: Date.today)
      # if content is the same, rails doesn't set new updated_at value
    end

  end

  def recent_studies
    silence_active_record { StudyJsonRecord.destroy_all } # temporary fix
    # start_date = fetch_start_date
    start_date = "2024-09-01"

    query_term = @api_client.query_term_for(start_date: start_date)
    @api_client.fetch_studies_paginated(query_term: query_term, page_size: 500) do |studies|
      import_studies(studies)
    end
  end

  def recently_updated
    silence_active_record do
      StudyJsonRecord.destroy_all # temporary fix
       Rails.logger.info("Deleted all StudyJsonRecords")
    end
    
    # TODO: capture total count and use the somewhere (load event?
    # TODO: show progress
    # TODO - handle errors -> propage up to the caller?
    total_count = nil
    page_token = nil
    start_date = fetch_start_date
    # start_date = "2024-07-30"

    loop do
      query_term = @api_client.query_term_for(start_date: start_date)
      # studies = @api_client.fetch_studies_by_date(start_date: start_date)
      response = @api_client.studies(page_token: page_token, query_term: query_term, page_size: 500)
      
      studies = response["studies"]
      total_count = response["totalCount"] if response["totalCount"]
      page_token = response["nextPageToken"]
      count = studies.size

      Rails.logger.info("Total Count: #{total_count}") if response["totalCount"]
      Rails.logger.info("Fetched #{count} studies")

      
      import_studies(response["studies"])
      break if page_token.nil? 
    end
    Rails.logger.info("Importing of #{total_count} StudyJsonRecords is completed")
  end

  private

  def import_studies(studies)
    silence_active_record do
      study_records = studies.map do |study_json|
        nct_id = study_json["protocolSection"]["identificationModule"]["nctId"]
        StudyJsonRecord.new(
          nct_id: nct_id,
          version: "2",
          content: study_json,
          download_date: Date.today.to_s,
          # don't need these fields?
          created_at: Time.now,
          updated_at: Time.now
        )
      end
      StudyJsonRecord.import(study_records)
      Rails.logger.info("Imported #{study_records.size} StudyJsonRecords")
    end
    
    
    # StudyJsonRecord.import(study_records), on_duplicate_key_update: {
    #   conflict_target: [:nct_id, :version],
    #   columns: [:content, :download_date, :updated_at]
    #   })
  end

  def fetch_start_date
    last_event = Support::LoadEvent
                  .where(event_type: 'incremental', status: 'complete')
                  .order(completed_at: :desc)
                  .first

    if last_event && last_event.completed_at
      # TODO: figure out the timezone, so we don't have to reprocess a day ago
      last_event.completed_at.to_date.days_ago(1)
    else
      Rails.logger.warn("No complete incremental events found, using default start date.")
      Date.today - 5 # or any default date you want to use
    end
  end
end