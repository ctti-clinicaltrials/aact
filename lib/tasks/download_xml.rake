namespace :import do
  namespace :full do
    task :run, [:force] => :environment do |t, params|
      if ![1].include? Date.today.day || args[:force]
        ClinicalTrials::Client.download_xml_file
      end
    end
  end
end
