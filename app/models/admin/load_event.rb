module Admin
  class LoadEvent < Admin::AdminBase
    extend Enumerize

    def complete(params={})
      return if self.completed_at.present?
      sc=params[:study_counts]
      self.status  = (params[:status] ?  params[:status] : 'complete')
      self.problems = params[:problems] if params[:problems]
      self.completed_at = Time.zone.now
      self.load_time = calculate_load_time
      if sc
        self.should_add = sc[:should_add]
        self.should_change = sc[:should_change]
        self.processed = sc[:processed]
      end
      self.save!
    end

    def add_problem(prob)
      self.problems = "#{self.problems} \n#{prob}"
    end

    def save_id_info(added_ids, changed_ids)
      self.description = '' if self.description.nil?
      self.description += "added:\n" + added_ids.join("\n")
      self.description += "\n\nchanged:\n" + changed_ids.join("\n")
      self.should_add=added_ids.size
      self.should_change=changed_ids.size
      self.save!
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
        should_add:     new,
        should_change: changed
      )
    end

    def email_message
      val = ''
      val += description if description
      if !problems.blank?
        val += "\n\nProblems encountered:\n\n"
        val += problems
      end
      val
    end

    def subject_line
      return "AACT #{Rails.env.capitalize} #{event_type.try(:capitalize)}" if event_type and event_type.include? 'backup'
      if problems.blank?
        title="AACT #{Rails.env.capitalize} #{event_type.try(:capitalize)} Load Notification. Status: #{status}"
      else
        status='failed'
        subject="AACT #{Rails.env.capitalize} #{event_type.try(:capitalize)} Load - PROBLEMS ENCOUNTERED"
      end

      if status != 'failed'
        if processed.nil? or processed == 0
          subject="AACT #{Rails.env.capitalize} #{event_type.try(:capitalize)} Load Notification. Nothing to load."
        else
          subject="#{title}. Added: #{should_add} Updated: #{should_change} Total: #{processed}"
        end
      end
      subject
    end

    def backup_subject_line
      subject="AACT #{Rails.env.capitalize} #{event_type.try(:capitalize)}"
    end

    def log(msg)
      stamped_message="\n#{Time.zone.now} #{msg}"
      self.description << stamped_message
      self.save!
      $stdout.puts stamped_message
      $stdout.flush
    end

    class AlreadyCompletedError < StandardError; end
    class IncorrectEventTypeError < StandardError; end
  end
end
