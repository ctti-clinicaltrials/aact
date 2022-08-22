namespace :aact do
  task :process, [] => :environment do
    updater = Util::Updater.new
    updater.start
  end

  task :delete_previous_month_files, [:file_type] => :environment do |t, args|
    last_month_start = Date.today.last_month.beginning_of_month
    last_month_end = Date.today.last_month.beginning_of_month.end_of_month+1
    files = FileRecord.where(file_type: args[:file_type]).
    where(created_at: last_month_start..last_month_end).
    order(created_at: :asc)
    arr_files = files.to_a
    first = arr_files.shift()
    arr_files.each do |file|
      file.destroy
    end
  end
end



