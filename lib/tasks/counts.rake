namespace :count do
  task nct_id_diff: [:environment] do
    StudyJsonRecord.data_verification_csv
  end
end
