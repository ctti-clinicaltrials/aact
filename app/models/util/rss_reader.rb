require 'rss'
require 'uri'

module Util
  class RssReader
    BASE_URL = 'https://clinicaltrials.gov'
    #https://clinicaltrials.gov/ct2/results/rss.xml?lup_d=4&count=10000

    attr_reader :changed_url, :added_url

    def initialize(days_back: 1)
      @changed_url = "#{BASE_URL}/ct2/results/rss.xml?lup_d=#{days_back}&count=10000"
      @added_url   = "#{BASE_URL}/ct2/results/rss.xml?rcv_d=#{days_back}&count=10000"
    end

    def get_changed_nct_ids
      tries ||= 5
      begin
        feed = RSS::Parser.parse(@changed_url, false)
        feed.items.map(&:guid).map(&:content)
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

    def get_added_nct_ids
      tries ||= 5
      begin
        feed = RSS::Parser.parse(@added_url, false)
        feed.items.map(&:guid).map(&:content)
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
