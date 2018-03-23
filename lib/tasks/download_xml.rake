namespace :download do
  namespace :xml do
    task :run, [:force] => :environment do |t, params|
      Util::Client.new.download_xml_files
    end
  end
end
