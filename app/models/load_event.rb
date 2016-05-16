class LoadEvent < ActiveRecord::Base
  extend Enumerize

  enumerize :event_type, in: %i(
    get_studies
    populate_studies
  )

  def complete
    if completed_at.present?
      raise AlreadyCompletedError
    end

    self.status = 'complete'
    self.completed_at = Time.now
    self.load_time = calculate_load_time

    save!
  end

  def calculate_load_time
    time = completed_at - created_at
    minutes, seconds = time.divmod(60)

    "#{minutes} minutes and #{seconds.round} seconds"
  end

  class AlreadyCompletedError < StandardError; end
end
