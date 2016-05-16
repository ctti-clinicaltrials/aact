require 'rails_helper'

describe LoadEvent do

  describe '#complete' do
    let!(:load_event) { create(:load_event) }

    it 'should not allow being completed twice' do
      load_event.complete

      expect(Proc.new {load_event.complete}).to raise_error(LoadEvent::AlreadyCompletedError)
    end
  end

  describe '#calculate_load_time' do
    it 'should return the difference in minutes and seconds' do
      load_event = LoadEvent.create

      Timecop.travel(5.minutes.from_now)

      load_event.complete

      expect(load_event.load_time).to eq('5 minutes and 0 seconds')
    end
  end

end
