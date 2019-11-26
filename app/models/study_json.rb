require 'open-uri'
# require 'action_view'
# require 'action_view/helpers'
include ActionView::Helpers::DateHelper
class StudyJson < ActiveRecord::Base
    def self.save_all_studies
      start_time = Time.current
      first_batch = json_data
      save_study_records(first_batch['FullStudiesResponse']['FullStudies'])
      # total_number is the number of studies available, meaning the total number in their database
      total_number = first_batch['FullStudiesResponse']['NStudiesAvail']
      # since I already saved the first hundred studies I start the loop after that point
      # studies must be retrieved in batches of 99,
      # using min and max to determine the study to start with and the study to end with respectively (in that batch)
      min = 101
      max = 200
      limit = (total_number/100.0).ceil
      
      for x in 1..limit
        fetch_studies(min, max)
        min += 100
        max += 100
        puts "Current Study Count #{StudyJsonRecord.count}"
        sleep 1
      end
      seconds = Time.now - start_time
      puts "finshed in #{time_ago_in_words(start_time)}"
      puts "total number we should have #{total_number}"
      puts "total number we have #{StudyJsonRecord.count}"
    end

    def self.fetch_studies(min=1, max=100)
      begin
        retries ||= 0
        puts "try ##{ retries }"
        url="https://clinicaltrials.gov/api/query/full_studies?expr=&min_rnk=#{min}&max_rnk=#{max}&fmt=json"
        data = json_data(url)['FullStudiesResponse']['FullStudies']
        save_study_records(data)
      rescue
        retry if (retries += 1) < 6
      end
    end

    def self.save_study_records(study_batch)
      study_batch.each do |study_data|
        save_single_study(study_data)
      end
    end

    def self.save_single_study(study_data)
      nct_id = study_data['Study']['ProtocolSection']['IdentificationModule']['NCTId']
      record = StudyJsonRecord.find_by(nct_id: nct_id) || StudyJsonRecord.new(nct_id: nct_id)
      record.content = study_data
      record.saved_study_at = nil 
      if record.save
        puts study_data['Study']['ProtocolSection']['IdentificationModule']['NCTId']
      else
        puts "failed to save #{nct_id}"
      end
    end

    def self.json_data(url='https://clinicaltrials.gov/api/query/full_studies?expr=&min_rnk=1&max_rnk=100&fmt=json')
      page = open(url)
      JSON.parse(page.read)
    end
end