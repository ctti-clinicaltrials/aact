require 'rails_helper'
require 'spec_helper'

describe UserEventMailer, type: :mailer do
  describe 'user event notification' do
    let!(:user) { User.new(:email=>'test@gmail.com', :first_name=>'Fname', :last_name=>'Lname', :username=>'username') }
    let(:msg) { described_class.send_msg('aact-admin@duke.edu', user.notification_subject_line('created')) }

    xit 'has expected subject line and DB username in body content' do
      expect(msg.subject).to eq('AACT Test user created: Fname Lname')
      expect(msg.body).to include('DB username:  username')
    end
  end

end
