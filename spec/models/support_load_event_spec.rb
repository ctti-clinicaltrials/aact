require 'rails_helper'
require 'timecop'

describe Support::LoadEvent do

  describe '#complete' do
    let!(:load_event) { create(:load_event) }

    it "returns the correct event type: incremental" do
      updater = Util::Updater.new(event_type: 'incremental')
      event_type = updater.instance_variable_get(:@params)[:event_type]
      expect(event_type).to eq('incremental')
    end

    it "returns the correct event type: full" do
      updater = Util::Updater.new(event_type: 'full')
      event_type = updater.instance_variable_get(:@params)[:event_type]
      expect(event_type).to eq('full')
    end

    it "returns the correct event type: restart" do
      updater = Util::Updater.new(event_type: 'restart')
      event_type = updater.instance_variable_get(:@params)[:event_type]
      expect(event_type).to eq('restart')
    end

    it "returns the default event type: incremental" do
      updater = Util::Updater.new
      event_type = updater.instance_variable_get(:@params)[:event_type] || 'incremental'
      expect(event_type).to eq('incremental')
    end
  end

  describe '#calculate_load_time' do
    it 'should return the difference in minutes and seconds' do
      load_event = Support::LoadEvent.create

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
          expect(Proc.new {load_event.generate_report(new: 1, changed: 3)}).to raise_error(Support::LoadEvent::IncorrectEventTypeError)
        end
      end
    end
  end
end
