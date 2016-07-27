namespace :create_calculated_values do
  task run: :environment do
    Study.create_calculated_values
  end
end

