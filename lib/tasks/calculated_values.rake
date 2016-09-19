namespace :create_calculated_values do
  task run: :environment do
    $stdout.puts "Creating calculated values..."
    $stdout.flush
    Study.create_calculated_values
  end
end

