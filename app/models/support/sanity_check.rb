# frozen_string_literal: true

module Support
  # Various quick sanity checks to make sure data is correct
  class SanityCheck < Support::SupportBase
    belongs_to :load_event
  end
end
