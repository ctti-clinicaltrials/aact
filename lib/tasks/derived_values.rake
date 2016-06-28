namespace :create_derived_values do
  task run: :environment do
    Study.create_derived_values
  end
end

