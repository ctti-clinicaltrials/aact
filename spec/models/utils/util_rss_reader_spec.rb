require 'rails_helper'

describe Util::RssReader do
  describe '#initialize' do

    context 'without a specified days_back arg' do
      it 'should generate the correct url' do
        changed_url = "https://clinicaltrials.gov/ct2/results/rss.xml?lup_d=1&count=1000"
        added_url   = "https://clinicaltrials.gov/ct2/results/rss.xml?rcv_d=1&count=1000"

        reader = described_class.new

        expect(reader.changed_url).to eq(changed_url)
        expect(reader.added_url).to eq(added_url)
      end
    end

    context 'with a specified days_back arg' do
      it 'should generate the correct url' do
        changed_url = "https://clinicaltrials.gov/ct2/results/rss.xml?lup_d=14&count=1000"
        added_url   = "https://clinicaltrials.gov/ct2/results/rss.xml?rcv_d=14&count=1000"

        reader = described_class.new(days_back: 14)

        expect(reader.changed_url).to eq(changed_url)
        expect(reader.added_url).to eq(added_url)
      end
    end

  end

  describe '#get_changed_nct_ids' do
    it 'should return an array of nct_ids' do
      reader  = described_class.new(days_back: 5)
      reader.set_changed_url(File.read(Rails.root.join('spec', 'support', 'xml_data', 'rss_feed.xml')))
      results=reader.get_changed_nct_ids

      expect(results.class).to eq(Array)
      expect(results.count).to eq(971)
    end
  end

end
