module Util
  class ApiReader
    BASE_URL = 'https://clinicaltrials.gov'
    #https://clinicaltrials.gov/ct2/results/rss.xml?lup_d=4&count=10000

    attr_reader :changed_url, :added_url, :date_since

    def initialize(days_back: 1)
      @date_since = Date.today - days_back.to_i
      @changed_url = "#{BASE_URL}/api/query/field_values?expr=AREA[LastUpdatePostDate]"\
                     "RANGE[#{@date_since.strftime('%m/%d/%Y')}, MAX]&field=NCTId&fmt=xml"
      @added_url = "#{BASE_URL}/api/query/field_values?expr=AREA[StudyFirstPostDate]"\
                   "RANGE[#{@date_since.strftime('%m/%d/%Y')}, MAX]&field=NCTId&fmt=xml"
    end

    def get_changed_nct_ids
      tries ||= 5
      begin
        root = Nokogiri::XML(Faraday.get(@changed_url).body)
        root.xpath('//FieldValue').map{ |field| field.text.strip }
      rescue  Exception => e
        if (tries -=1) > 0
          puts "Failed: #{@changed_url}.  trying again..."
          puts "Error: #{e}"
          retry
        else #give up & return empty array
          []
        end
      end
    end

    def get_added_nct_ids
      tries ||= 5
      begin
        root = Nokogiri::XML(Faraday.get(@added_url).body)
        root.xpath('//FieldValue').map{ |field| field.text.strip }
      rescue  Exception => e
        if (tries -=1) > 0
          puts "Failed: #{@added_url}.  trying again..."
          puts "Error: #{e}"
          retry
        else #give up & return empty array
          []
        end
      end
    end

    def set_changed_url(cmd)
      @changed_url=cmd
    end
  end
end
