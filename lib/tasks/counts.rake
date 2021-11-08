namespace :count do
  task nct_id_diff: [:environment] do
    StudyJsonRecord.data_verification_csv
  end

  desc 'get the difference between our database and the Clinical Trials Study Statistics API endpoint'
  task :study_statistics_diff, [:schema]  => :environment do |t, args|
    Verifier.refresh(args)
  end
end
