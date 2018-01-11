class DatabaseActivity < Admin::AdminBase
  #  pg log files are created for each day of the week:  Mon-Sun.  So there are always 7 files.
  #  we can either pull in data from one or all of these files.  If the day is not specified, iterate over all the files

  def self.populate(params={:day=>nil})

    if params[:day].nil?  # Iterate thru all 7 log files if a day isn't specified.
      ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'].each{|day|
        entries=Util::FileManager.db_log_file_content({:day=>day})
        process_entries(entries)
      }
    else
      entries=Util::FileManager.db_log_file_content({:day=>params[:day]})
      process_entries(entries)
    end
  end

  def self.process_entries(entries)
    previous_entry=nil
    file_name=entries.try(:path)
    entries.each {|entry|
      new_entry=new.create_entry(entry)
      if new_entry.log_date.nil?  # if no date, assume this is a continuation of previous entry
        previous_entry.description = previous_entry.description + new_entry.description
      else
        previous_entry=new_entry
        previous_entry.file_name=file_name
        previous_entry.save!
      end
    }
  end

  def create_entry(entry)
    self.log_date=entry.split(/ EDT >/).first.split('< ').last.strip
    self.log_type=log_type_from(entry)
    self.description=log_message_from(entry)
    self
  end

  def log_types
    ['DETAIL','ERROR','FATAL','HINT','LOG','STATEMENT','WARNING','CONTEXT']
  end

  def log_type_from(entry)
    self.log_types.each{|type| return type if entry.include?(type) }
    return 'UNKNOWN'
  end

  def log_message_from(entry)
    log_types.each{|t|
      return entry.split("#{t}:").last.strip if entry.include?(t)
    }
    return entry
  end

end
