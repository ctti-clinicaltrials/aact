module ClinicalTrials
  class LoadEvent < ActiveRecord::Base
    extend Enumerize

    enumerize :event_type, in: %w(
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

    def generate_report(new:, changed:)
      if event_type != 'populate_studies'
        raise IncorrectEventTypeError
      end

      update(
        new_studies:     new,
        changed_studies: changed
      )
    end

    class AlreadyCompletedError < StandardError; end
    class IncorrectEventTypeError < StandardError; end
  end
end
