require 'open-uri'
# require 'action_view'
# require 'action_view/helpers'
include ActionView::Helpers::DateHelper
class StudyJson < ActiveRecord::Base
    def self.get_data
      first_batch = json_data
      total_number = first_batch["FullStudiesResponse"]["NStudiesFound"]
      min = 1
      max = 100
      limit = (total_number/100.0).ceil
      start_time = Time.current
      puts total_number
      for x in 0..1
        puts x
        found_studies(min, max)
        min += 100
        max += 100
        sleep 1
      end
      seconds = Time.now - start_time
      puts "finshed in #{time_ago_in_words(start_time)}"
    # "NStudiesAvail":323007,
    # "NStudiesFound":323007,
    # "MinRank":1,
    # "MaxRank":100,
    # "NStudiesReturned":100,
    end

    def self.found_studies(min=1, max=100)
      begin
        retries ||= 0
        puts "try ##{ retries }"
        url="https://clinicaltrials.gov/api/query/full_studies?expr=&min_rnk=#{min}&max_rnk=#{max}&fmt=json"
        data = json_data(url)["FullStudiesResponse"]
        puts "min #{data["MinRank"]}"
        puts "max #{data["MaxRank"]}"
      rescue
        retry if (retries += 1) < 4
      end
    end


    def self.json_data(url='https://clinicaltrials.gov/api/query/full_studies?expr=&min_rnk=1&max_rnk=100&fmt=json')
      page = open(url)
      JSON.parse(page.read)
    end
end