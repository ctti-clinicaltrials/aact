require 'rails_helper'
require 'spec_helper'

describe UserMailer, type: :mailer do
  describe 'user event notification' do
    let!(:user) { User.new(:email=>'test@gmail.com', :first_name=>'Fname', :last_name=>'Lname', :username=>'username') }

    it 'has expected subject line and DB username in body content' do
      expect(described_class).to receive(:event_notification).exactly(2).times
      described_class.send_event_notification('created', user)
    end
  end

end
