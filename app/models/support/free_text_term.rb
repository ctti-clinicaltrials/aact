require 'active_support/all'
module Support
  class FreeTextTerm < SupportBase
    self.table_name = 'analyzed_free_text_terms'
    self.primary_key = :identifier
    belongs_to :category, class_name: 'Support::Category', foreign_key: 'identifier'
    has_many :categories, class_name: 'Support::Category', foreign_key: 'identifier'

    def self.for_category(category)
      joins("INNER JOIN categorized_terms ON categorized_terms.identifier = analyzed_free_text_terms.identifier AND categorized_terms.category='#{category}'")
    end

    def self.term_list_for_category(category)
      terms=for_category(category)
      term_array=terms.pluck(:term).uniq.sort.map{|t| {'term' => t, 'type'=>'Free Text', 'note'=>'', 'year'=>'','identifiers'=>'N/A'} }
      terms.each{ |obj|
        term_array.each{ |hash|
          if hash['term'] == obj.term
            if obj.note && hash['note'] != obj.note
              if hash['note'].size > 1
                hash['note'] = hash['note'] + '; ' + obj.note if !hash['note'].include? obj.note
              else
                hash['note'] = obj.note
              end
            end

            if obj.year
              if hash['year'].size > 1
                hash['year'] =  hash['year'] + '; ' + obj.year if !hash['year'].include? obj.year
              else
                hash['year'] =  obj.year
              end
            end
          end
        }
      }
      term_array
    end

  end
end

