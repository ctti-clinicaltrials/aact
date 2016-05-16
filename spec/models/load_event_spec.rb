require 'rails_helper'

describe LoadEvent do

  describe '#complete' do
    let!(:load_event) { create(:load_event) }

    it 'should not allow being completed twice' do
      load_event.complete

      expect(Proc.new {load_event.complete}).to raise_error(LoadEvent::AlreadyCompletedError)
    end
  end

end
