namespace :calculated_values do
  task create: :environment do
    $stdout.puts "Creating calculated values..."
    $stdout.flush
    ClinicalTrials::Updater.new.create_calculated_values
  end
end

