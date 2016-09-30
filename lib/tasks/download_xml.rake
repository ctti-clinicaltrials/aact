namespace :import do
  namespace :xml do
    task :run, [:force] => :environment do |t, params|
      ClinicalTrials::Client.download_xml_file
    end
  end
end
