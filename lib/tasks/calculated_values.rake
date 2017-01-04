namespace :calculated_values do
  task create: :environment do
    ClinicalTrials::Updater.new.create_calculated_values
  end
end

