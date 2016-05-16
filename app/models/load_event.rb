class LoadEvent < ActiveRecord::Base
  attr_accessor :start_time

  def start_clock
    @start_time=Time.now
  end

  def complete
    if completed_at.present?
      raise AlreadyCompletedError
    end

    update(status: 'complete', completed_at: Time.now)
  end

  class AlreadyCompletedError < StandardError; end
end
