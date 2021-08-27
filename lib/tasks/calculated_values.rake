namespace :calculated_values do
  task create: :environment do
    Util::Updater.new.create_calculated_values
    Util::Updater.new.set_downcase_terms
  end
end

