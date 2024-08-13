# frozen_string_literal: true

module Support
  class LoadEvent < Support::SupportBase
    self.table_name = 'support.load_events'

    has_many :load_issues

    SINGLE_STUDY_TABLES = %w[
      brief_summaries
      designs
      detailed_descriptions
      eligibilities
      participant_flows
      calculated_values
      studies
    ].freeze

    PARENT_CHILD = {
      studies: %i[outcomes reported_events],
      outcomes: %i[outcome_analyses outcome_measurements],
      outcome_analyses: [:outcome_analysis_groups]
    }.freeze

    extend Enumerize

    has_many :sanity_checks
    has_one  :verifier

    def complete(params = {})
      return if completed_at.present?

      sc = params[:study_counts]
      self.status = (params[:status] || 'complete')
      self.problems = params[:problems] if params[:problems]
      self.completed_at = Time.zone.now
      self.load_time = calculate_load_time
      if sc
        self.should_add = sc[:should_add]
        self.should_change = sc[:should_change]
        self.processed = sc[:processed]
      end
      save!
    end

    def add_problem(prob)
      self.problems = "#{problems} \n#{prob}"
    end

    def save_id_info(added_ids, changed_ids)
      self.description = '' if description.nil?
      self.description += "added:\n" + added_ids.join("\n")
      self.description += "\n\nchanged:\n" + changed_ids.join("\n")
      self.should_add = added_ids.size
      self.should_change = changed_ids.size
      save!
    end

    def calculate_load_time
      time = completed_at - created_at
      minutes, seconds = time.divmod(60)
      val = "#{minutes} minutes and #{seconds.round} seconds"
      val
    end

    def generate_report(new:, changed:)
      raise IncorrectEventTypeError if event_type != 'populate_studies'

      update(
        should_add: new,
        should_change: changed
      )
    end

    def email_message
      val = ''
      val += description if description
      unless problems.blank?
        val += "\n\nProblems encountered:\n\n"
        val += problems
      end
      val
    end

    def subject_line
      return "AACT #{Rails.env.capitalize} #{event_type.try(:capitalize)}" if event_type&.include?('backup')

      if problems.blank?
        title = "AACT #{Rails.env.capitalize} #{event_type.try(:capitalize)} Load Notification. Status: #{status}"
      else
        status = 'failed'
        subject = "AACT #{Rails.env.capitalize} #{event_type.try(:capitalize)} Load - PROBLEMS ENCOUNTERED"
      end

      if status != 'failed'
        if processed.nil? || (processed == 0)
          subject = "AACT #{Rails.env.capitalize} #{event_type.try(:capitalize)} Load Notification. Nothing to load."
        else

          subject = "#{title}. Added: #{should_add} Updated: #{should_change} Total: #{processed} Existing: #{ClinicalTrialsApi.number_of_studies}"
        end
      end
      subject.squish
    end

    def backup_subject_line
      subject = "AACT #{Rails.env.capitalize} #{event_type.try(:capitalize)}"
    end

    def log(msg)
      self.description << "#{msg}\n"
      save!
    end

    # find all the duplicated entries in tables which should have only
    # one row per study
    def check_for_duplicates(schema)
      SINGLE_STUDY_TABLES.each do |table_name|
        results = ActiveRecord::Base.connection.execute(
          "SELECT nct_id, count(*)
          FROM #{schema}.#{table_name}
          GROUP BY nct_id
          HAVING COUNT(*) > 1"
        )
        results.values.each do |row|
          puts 'check_for_duplicates: row: ' + row.to_s
          sanity_checks.create(
            table_name: table_name,
            nct_id: row.first,
            row_count: row.last,
            check_type: 'duplicate'
          )
        end
      end
    end

    # find all the studies which are orphaned
    def check_for_orphans(schema)
      PARENT_CHILD.each do |parent, children|
        children.each do |child|
          query = orphan_check_sql(schema, parent, child)
          ActiveRecord::Base.connection.execute(query).each do |orphan|
            sanity_checks.create(
              nct_id: orphan['nct_id'],
              table_name: child,
              check_type: 'orphan',
              description: "Orphaned from #{parent}"
            )
          end
        end
      end
    end

    def orphan_check_sql(schema, parent, child)
      "SELECT  distinct l.nct_id
        FROM    #{schema}.#{child} l
      LEFT JOIN #{schema}.#{parent} r
          ON  r.nct_id = l.nct_id
        WHERE  r.nct_id IS NULL "
    end

    def run_sanity_checks(schema = 'ctgov')
      check_for_orphans(schema)
      check_for_duplicates(schema)
    end

    class AlreadyCompletedError < StandardError; end
    class IncorrectEventTypeError < StandardError; end
  end
end
