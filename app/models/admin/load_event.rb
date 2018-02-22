module Admin
  class LoadEvent < Admin::AdminBase
      extend Enumerize

      def complete(params={})
        return if self.completed_at.present?
        sc=params[:study_counts]
        self.status  = (params[:status] ?  params[:status] : 'complete')
        self.problems = params[:problems] if params[:problems]
        self.completed_at = Time.now
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
        if problems
          val += "\n\nProblems encountered:\n\n"
          val += problems
        end
        val
      end

      def log(msg)
        stamped_message="\n#{Time.now} #{msg}"
        self.description << stamped_message
        self.save!
        $stdout.puts stamped_message
        $stdout.flush
      end

      class AlreadyCompletedError < StandardError; end
      class IncorrectEventTypeError < StandardError; end
  end
end
