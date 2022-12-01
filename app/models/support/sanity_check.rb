# frozen_string_literal: true

module Support
  # Various quick sanity checks to make sure data is correct
  class SanityCheck < Support::SupportBase
    self.table_name = 'support.sanity_checks'
    belongs_to :load_event
  end
end
