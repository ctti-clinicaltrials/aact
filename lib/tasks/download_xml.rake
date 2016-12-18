namespace :import do
  namespace :xml do
    task :run, [:force] => :environment do |t, params|
      ClinicalTrials::Client.new.download_xml_files
    end
  end
end
