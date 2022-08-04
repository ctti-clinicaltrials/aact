namespace :aact do
  task :process, [] => :environment do
    updater = Util::Updater.new
    updater.start
  end

  task :delete_previous_month_files, [] => :environment do
    files = FileRecord.all
    arr_files = files.to_a
    # sort array here
    # start = Date.today.last_month.beginning_of_month
    # (start..start.end_of_month).each do |date|
    first = arr_files.shift()
      arr_files.each do |file|
      file.destroy
      end
  end

    # task :create_previous_month_files, [] => :environment do
    #   start = Date.today. last_month.beginning_of_month
    #   (start..start.end_of_month).each do |date|
    #   # puts date
    #   FileRecord. create(file_type:'snapshot', created_at: date)
    #   end
    # end
end



