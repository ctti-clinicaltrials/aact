require 'active_support/all'
module Support
  class Category < SupportBase
    self.table_name = 'categorized_terms'
    self.primary_key = :identifier
    has_many :mesh_terms, class_name: 'Support::MeshTerm', foreign_key: 'identifier'
    has_many :free_text_terms, class_name: 'Support::FreeTextTerm', foreign_key: 'identifier'
    belongs_to :mesh_term, class_name: 'Support::MeshTerm', foreign_key: 'identifier'
    belongs_to :free_text_term, class_name: 'Support::FreeTextTerm', foreign_key: 'identifier'

    def self.categories
      uniq.pluck(:category).sort
    end

  end
end

