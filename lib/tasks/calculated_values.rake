namespace :calculated_values do
  task create: :environment do
    Util::Updater.new.create_calculated_values
    Util::Updater.new.set_downcase_mesh_terms
  end
end

