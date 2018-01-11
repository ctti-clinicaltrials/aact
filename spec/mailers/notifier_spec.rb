require 'rails_helper'
require 'spec_helper'

describe Notifier, type: :mailer do
  describe 'instructions' do
    let!(:event) {Admin::LoadEvent.new(:description=>'desc', :problems=>'probs')}
    let(:msg) { described_class.send_msg('test@gmail.com',event) }

    it 'renders the subject' do
      expect(msg.subject).to eq('AACT Test Load Notification. Nothing to load.')
    end

    it 'sends to the admin email' do
      expect(msg.to.first).to eq('test@gmail.com')
    end
  end
end
