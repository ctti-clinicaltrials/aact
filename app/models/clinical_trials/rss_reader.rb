require 'rss'
require 'uri'

module ClinicalTrials
  class RssReader
    BASE_URL = 'https://clinicaltrials.gov'
    #https://clinicaltrials.gov/ct2/results/rss.xml?rcv_d=30&lup_d=30&show_rss=Y&sel_rss=mod30&count=10000

    attr_reader :changed_url, :added_url

    def initialize(days_back: 1)
      @changed_url = "#{BASE_URL}/ct2/results/rss.xml?lup_d=#{days_back}&recrs=a&count=10000"
      @added_url   = "#{BASE_URL}/ct2/results/rss.xml?rcv_d=#{days_back}&show_rss=Y&count=10000"
    end

    def get_changed_nct_ids(rss: @changed_url)
      feed = RSS::Parser.parse(rss, false)
      feed.items.map(&:guid).map(&:content)
    end

    def get_added_nct_ids(rss: @added_url)
      feed = RSS::Parser.parse(rss, false)
      feed.items.map(&:guid).map(&:content)
    end
  end
end
