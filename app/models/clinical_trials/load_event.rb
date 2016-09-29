module ClinicalTrials
  class LoadEvent < ActiveRecord::Base
    extend Enumerize

    def complete(params={})
      raise AlreadyCompletedError if self.completed_at.present?
      self.status  = (params[:status] ?  params[:status] : 'complete')
      self.completed_at = Time.now
      self.load_time = calculate_load_time
      self.new_studies = params[:new_studies]
      self.changed_studies = params[:changed_studies]
      self.save!
    end

    def add_problem(errors={})
      err="\n#{errors[:name]}"
      desc="\n#{errors[:first_backtrace_line]}"
      self.problems = "#{self.problems}#{err}"
      self.problems = "#{self.problems}#{desc}"
      $stdout.puts err
      $stdout.puts desc
      $stdout.flush
    end

    def calculate_load_time
      time = self.completed_at - self.created_at
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

    def log(msg)
      stamped_message="\n#{Time.now.to_formatted_s(:db)} #{msg}"
      self.description << stamped_message
      self.save!
      $stdout.puts stamped_message
      $stdout.flush
    end

    def show_progress(study_counter, nct_id,action)
      if study_counter % 1000 == 0
        self.description << "\n#{action}: #{study_counter} (#{nct_id})"
        self.save!
      else
        self.description << '.' if study_counter % 100 == 0
      end
    end

    class AlreadyCompletedError < StandardError; end
    class IncorrectEventTypeError < StandardError; end
  end
end
