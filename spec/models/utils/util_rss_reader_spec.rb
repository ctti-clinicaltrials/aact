require 'rails_helper'

describe Util::RssReader do
  describe '#initialize' do

    context 'without a specified days_back arg' do
      it 'should generate the correct url' do
        changed_url = "https://clinicaltrials.gov/ct2/results/rss.xml?lup_d=1&cond=&count=1000"
        added_url   = "https://clinicaltrials.gov/ct2/results/rss.xml?rcv_d=1&cond=&count=1000"

        reader = described_class.new

        expect(reader.changed_url).to eq(changed_url)
        expect(reader.added_url).to eq(added_url)
      end
    end

    context 'with a specified days_back arg' do
      it 'should generate the correct url' do
        changed_url = "https://clinicaltrials.gov/ct2/results/rss.xml?lup_d=14&cond=&count=1000"
        added_url   = "https://clinicaltrials.gov/ct2/results/rss.xml?rcv_d=14&cond=&count=1000"

        reader = described_class.new(days_back: 14)

        expect(reader.changed_url).to eq(changed_url)
        expect(reader.added_url).to eq(added_url)
      end
    end

  end

  describe '#get_changed_nct_ids' do
    it 'should return an array of nct_ids' do
      reader  = described_class.new(days_back: 5)
      puts "Step: 1"
      reader.set_changed_url(File.read(Rails.root.join('spec', 'support', 'xml_data', 'rss_feed.xml')))

      puts "Step: 2"
      feed = RSS::Parser.parse(File.read(Rails.root.join('spec', 'support', 'xml_data', 'rss_feed.xml')), false)
      feed2 = RSS::Parser.parse('', false)
      allow(RSS::Parser).to receive(:parse).and_return(feed, feed2)
      results=reader.get_changed_nct_ids

      puts "Step: 3"
      expect(results.class).to eq(Array)

      puts "Step: 4"
      expect(results.count).to eq(971)
    end
  end

end
