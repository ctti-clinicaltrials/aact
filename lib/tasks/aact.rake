include ActionView::Helpers::NumberHelper

namespace :aact do
  task :process, [] => :environment do
    updater = Util::Updater.new
    updater.start
  end

  task :delete_previous_month_files, [:file_type] => :environment do |t, args|
    today = Date.today
    last_month_start = today.last_month.beginning_of_month
    last_month_end = today.last_month.beginning_of_month.end_of_month+1

    # load all of last month's files
    files = FileRecord.where(file_type: args[:file_type]).
    where(created_at: last_month_start..last_month_end).
    order(created_at: :asc).to_a

    keep = files.shift # remove the first file
    unless keep
      puts "no files found"
      next
    end

    puts "keeping #{keep.id} #{keep.file_type} - #{keep.created_at} #{number_to_human_size(keep.file_size)}\n\n"
    files.each do |file|
      puts "removing #{file.id} #{file.file_type} - #{file.created_at} #{number_to_human_size(file.file_size)}"
      file.destroy
    end
    puts "removed #{files.count} files"
  end
end



