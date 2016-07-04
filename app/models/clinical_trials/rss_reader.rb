require 'rss'
require 'uri'

module ClinicalTrials
  class RssReader
    BASE_URL = 'https://clinicaltrials.gov'

    attr_reader :url

    def initialize(days_back: 1)
      @url = "#{BASE_URL}/ct2/results/rss.xml?rcv_d=&lup_d=#{days_back}&show_rss=Y&sel_rss=mod#{days_back}&count=10000"
    end

    def get_changed_nct_ids(rss: @url)
      feed = RSS::Parser.parse(rss, false)
      feed.items.map(&:guid).map(&:content)
    end
  end
end
