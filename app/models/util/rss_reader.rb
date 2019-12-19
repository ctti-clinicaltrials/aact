require 'rss'
require 'uri'

module Util
  class RssReader
    BASE_URL = 'https://clinicaltrials.gov'
    PAGE_SIZE = 1000
    #https://clinicaltrials.gov/ct2/results/rss.xml?lup_d=4&count=10000

    attr_reader :changed_url, :added_url

    def initialize(days_back: 1)
      @changed_url = "#{BASE_URL}/ct2/results/rss.xml?lup_d=#{days_back}&count=#{PAGE_SIZE}"
      @added_url   = "#{BASE_URL}/ct2/results/rss.xml?rcv_d=#{days_back}&count=#{PAGE_SIZE}"
    end

    def get_changed_nct_ids
      list = []
      start = 0
      loop do
        result = get_changed_nct_ids_batch(start)
        list += result
        start += PAGE_SIZE
        break if result.length == 0
      end
      list
    end

    def get_added_nct_ids
      list = []
      start = 0
      loop do
        result = get_added_nct_ids_batch(start)
        list += result
        start += PAGE_SIZE
        break if result.length == 0
      end
      list
    end

    def get_changed_nct_ids_batch(start)
      tries ||= 5
      begin
        feed = RSS::Parser.parse("#{@changed_url}&start=#{start}", false)
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

    def get_added_nct_ids_batch(start)
      tries ||= 5
      begin
        feed = RSS::Parser.parse("#{@added_url}&start=#{start}", false)
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
