require 'rails_helper'
require 'spec_helper'

describe Notifier, type: :mailer do
  describe 'user event notification' do
    let!(:user) { User.new(:email=>'test@gmail.com', :first_name=>'Fname', :last_name=>'Lname', :username=>'username') }
    let(:msg) { described_class.send_user_event_msg('test@gmail.com', user, 'created') }

    it 'has expected subject line and DB username in body content' do
      expect(msg.subject).to eq('AACT Test user created: Fname Lname')
      expect(msg.body).to include('DB username:  username')
    end
  end

  describe 'load notification when nothing to load' do
    let!(:event) {Admin::LoadEvent.new(:description=>'desc', :problems=>'')}
    let(:msg) { described_class.send_msg('test@gmail.com',event.subject_line, event.email_message) }

    it 'msg has expected content' do
      expect(msg.subject).to eq('AACT Test Load Notification. Nothing to load.')
      expect(msg.body).to eq('desc')
      expect(msg.to.first).to eq('test@gmail.com')
    end
  end

  describe 'load notification when problems encountered' do
    let!(:event) {Admin::LoadEvent.new(:description=>'desc', :problems=>'a problem',:should_add=>'1',:should_change=>'1', :processed=>'2')}
    let(:msg) { described_class.send_msg('test@gmail.com',event.subject_line, event.email_message) }

    it 'msg has expected content' do
      expect(msg.subject).to eq('AACT Test Load - PROBLEMS ENCOUNTERED')
      expect(msg.body).to include('desc')
      expect(msg.body).to include('Problems encountered')
      expect(msg.body).to include('a problem')
    end
  end

  describe 'load notification when no problems encountered' do
    let!(:event) {Admin::LoadEvent.new(:status=>'completed', :description=>'desc', :problems=>'',:should_add=>'1',:should_change=>'1', :processed=>'2')}
    let(:msg) { described_class.send_msg('test@gmail.com',event.subject_line, event.email_message) }

    it 'msg has expected content' do
      expect(msg.subject).to eq('AACT Test Load Notification. Status: completed. Added: 1 Updated: 1 Total: 2')
      expect(msg.body).to include('desc')
      expect(msg.body).not_to include('Problems encountered')
    end
  end

end
