require 'rails_helper'

describe ClinicalTrials::RssReader do
  describe '#initialize' do

    context 'without a specified days_back arg' do
      it 'should generate the correct url' do
        changed_url = "https://clinicaltrials.gov/ct2/results/rss.xml?rcv_d=&lup_d=1&sel_rss=mod1&recrs=a&count=10000"
        added_url = "https://clinicaltrials.gov/ct2/results/rss.xml?rcv_d=1&lup_d=&sel_rss=new1&recrs=a&count=10000"

        reader = described_class.new

        expect(reader.changed_url).to eq(changed_url)
        expect(reader.added_url).to eq(added_url)
      end
    end

    context 'with a specified days_back arg' do
      it 'should generate the correct url' do
        changed_url = "https://clinicaltrials.gov/ct2/results/rss.xml?rcv_d=&lup_d=14&sel_rss=mod14&recrs=a&count=10000"
        added_url = "https://clinicaltrials.gov/ct2/results/rss.xml?rcv_d=14&lup_d=&sel_rss=new14&recrs=a&count=10000"

        reader = described_class.new(days_back: 14)

        expect(reader.changed_url).to eq(changed_url)
        expect(reader.added_url).to eq(added_url)
      end
    end

  end

  describe '#get_changed_nct_ids' do
    it 'should return an array of nct_ids' do
      reader  = described_class.new(days_back: 5)
      results = reader.get_changed_nct_ids(rss: File.read(Rails.root.join('spec', 'support', 'xml_data', 'rss_feed.xml')))

      expect(results.class).to eq(Array)
      expect(results.count).to eq(971)
    end
  end

end
