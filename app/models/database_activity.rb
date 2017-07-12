class DatabaseActivity < AdminBase

  def self.populate
    #Util::FileManager.db_log_file_content({:db_name=>ENV['S3_BUCKET_NAME']}).each {|log|
    Util::FileManager.db_log_file_content({:db_name=>'aact-prod'}).each {|log|
     log_time=nil
     log_message=''
     ip_addr=nil
     log_type=nil
     file_name=log[:file_name].split('error/postgresql.log.').last
     exists=(where('file_name=?',file_name).size > 0)
     unless exists or file_name=='error/postgres.log'  # If data from log file already loaded, skip it.
       entries=log[:content].split(/\n/)
       entries.each{|entry|
         if entry.include?('UTC:')
           if !log_type.nil? and !log_time.nil? #  save previous entry.  If there is no log type, this is a continuation of the previous entry
             new({:file_name=>file_name.strip, :log_date=>log_time, :log_type=>log_type.strip, :description=>log_message.strip, :ip_address=>ip_addr.try(:strip)}).save!
           end
           log_type=log_type_from(entry)
           log_time=entry.split(/UTC:/).first.strip.to_datetime if log_time.nil?
           log_message=log_message_from(entry)
           ip_addr=ip_addr_from(entry)
         else
           log_message=log_message+entry
         end
         # save last entry in the log file
         if !log_type.nil? and !log_time.nil?
           new({:file_name=>file_name.strip, :log_date=>log_time, :log_type=>log_type.strip, :description=>log_message.strip, :ip_address=>ip_addr.try(:strip)}).save!
         end
       }
     end
     }
  end

  def self.log_types
    ['DETAIL','ERROR','FATAL','HINT','LOG','STATEMENT','WARNING','CONTEXT']
  end

  def self.log_type_from(entry)
    self.log_types.each{|type| return type if entry.include?(type) }
    return 'UNKNOWN'
  end

  def self.log_message_from(entry)
    self.log_types.each{|type|
      return entry.split("#{type}:").last.strip if entry.include?(type)
    }
    return "Unknown type in #{entry}?"
  end

  def self.ip_addr_from(entry)
    possible_ip_addr=entry.split(':aact@aact:').first.split('UTC:').last.split('(').first
    possible_ip_addr=(entry.split('UTC::').last.split(']:').first) if possible_ip_addr.nil?
    return '[unknown]@[unknown]' if possible_ip_addr.include?("[unknown]@[unknown]")
    return nil if !(possible_ip_addr.match /^:@:/).nil?
    self.log_types.each{|type|
      return possible_ip_addr.split(":#{type}:").first.strip if possible_ip_addr.include?(type)
    }
    possible_ip_addr
  end

end
