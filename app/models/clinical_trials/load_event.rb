module ClinicalTrials
  class LoadEvent < ActiveRecord::Base
    extend Enumerize

    enumerize :event_type, in: %w(
      get_studies
      populate_studies
      incremental_update
      full_update
      table_export
    )

    def self.start(type)
      create(event_type: type, created_at: Time.now)
    end

    def complete(params={})
      raise AlreadyCompletedError if completed_at.present?
      status      = (params[:status] ?  params[:status] : 'complete')
      description = params[:description]
      errors      = "Errors: \n#{params[:errors].join('\n')}" if params[:errors]
      description << errors if errors
      self.description = description
      self.status = status
      self.completed_at = Time.now
      self.load_time = calculate_load_time
      self.new_studies = params[:new_studies]
      self.changed_studies = params[:changed_studies]
      self.save!
    end

    def calculate_load_time
      time = completed_at - created_at
      minutes, seconds = time.divmod(60)
      val="#{minutes} minutes and #{seconds.round} seconds"
      val
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
