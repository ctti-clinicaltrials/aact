require 'rails_helper'
require 'spec_helper'

describe Notifier, type: :mailer do
  let(:stub_request_headers) { {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v2.1.0' } }
  let(:study_statistics_body) {File.read('spec/support/json_data/study_statistics.json') }
  let(:mailer_stub) { stub_request(:get, 'https://classic.clinicaltrials.gov/api//info/study_statistics?fmt=json').with(headers: stub_request_headers).to_return(:status => 200, :body => study_statistics_body, :headers => {}) }
  let(:msg) { described_class.send_msg('test@gmail.com', event) }

  before do
    mailer_stub
  end
  describe 'load notification when nothing to load' do
    let!(:event) {Support::LoadEvent.new(:description=>'desc', :problems=>'')}

    it 'msg has expected content' do
      expect(msg.subject).to eq('AACT Test Load Notification. Nothing to load.')
      expect(msg.body).to include('desc')
      expect(msg.to.first).to eq('test@gmail.com')
    end
  end

  describe 'load notification when problems encountered' do
    let!(:event) {Support::LoadEvent.new(:description=>'desc', :problems=>'a problem',:should_add=>'1',:should_change=>'1', :processed=>'2')}

    it 'msg has expected content' do
      expect(msg.subject).to eq('AACT Test Load - PROBLEMS ENCOUNTERED')
      expect(msg.body).to include('desc')
      expect(msg.body).to include('Problems encountered')
      expect(msg.body).to include('a problem')
    end
  end

  describe 'load notification when no problems encountered' do
    let!(:event) {Support::LoadEvent.new(:status=>'completed', :description=>'desc', :problems=>'',:should_add=>'1',:should_change=>'1', :processed=>'2')}

    it 'msg has expected content' do
      expect(msg.subject).to eq('AACT Test Load Notification. Status: completed. Added: 1 Updated: 1 Total: 2 Existing: 385281')
      expect(msg.body).to include('desc')
      expect(msg.body).not_to include('Problems encountered')
    end
  end

end
