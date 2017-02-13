class DatabaseLog < AdminBase

  def self.populate_from_aws
    ClinicalTrials::FileManager.db_log_file_content({:db_name=>'aact-prod'}).each {|log|
     log_time=nil
     log_message=''
     ip_addr=nil
     file_name=log[:file_name]
     exists=(where('file_name=?',file_name).size > 0)
     unless exists
       entries=log[:content].split(/\n/)
       entries.each{|entry|
         if entry.include?('UTC:')
           if !log_time.nil?
             new({:file_name=>file_name, :log_date=>log_time, :description=>log_message, :ip_address=>ip_addr}).save!
           end
           log_time=entry.split(/UTC:/).first.strip.to_datetime
           log_message=entry.split(/UTC:/).last.strip.split(/:LOG:/).last.strip
           if log_message.include?('STATEMENT:')
             ip_addr=entry.split(':aact@aact:').first
             log_message=entry.split('STATEMENT:').last
           end
         else
           log_message=log_message+entry
         end
       }
     end
     }
  end

end
