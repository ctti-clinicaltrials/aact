require 'rails_helper'

describe ClinicalTrials::LoadEvent do

  describe '#complete' do
    let!(:load_event) { create(:load_event) }

    xit 'should not allow being completed twice' do
      load_event.complete
      expect(Proc.new {load_event.complete}).to raise_error(ClinicalTrials::LoadEvent::AlreadyCompletedError)
    end
  end

  describe '#calculate_load_time' do
    it 'should return the difference in minutes and seconds' do
      load_event = ClinicalTrials::LoadEvent.create

      Timecop.travel(5.minutes.from_now)

      load_event.complete

      expect(load_event.load_time).to eq('5 minutes and 0 seconds')
    end
  end

  describe '#generate_report' do
    context 'success' do
      let!(:load_event) { create(:load_event, event_type: 'populate_studies') }

      it 'should update the new and changed columns' do
        load_event.generate_report(new: 5, changed: 12)

        expect(load_event.should_add).to eq(5)
        expect(load_event.should_change).to eq(12)
      end
    end

    context 'failure' do
      context 'when not a populate_studies event type' do
        let!(:load_event) { create(:load_event, event_type: 'get_studies') }

        it 'should raise an error' do
          expect(Proc.new {load_event.generate_report(new: 1, changed: 3)}).to raise_error(ClinicalTrials::LoadEvent::IncorrectEventTypeError)
        end
      end
    end

  end

end
