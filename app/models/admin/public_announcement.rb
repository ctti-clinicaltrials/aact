require 'active_support/all'
module Admin
  class PublicAnnouncement < Admin::AdminBase

    def self.populate(string)
      begin
        clear_load_message
        new(:description=>string).save!
      rescue => error
        # no guarantee the AACT Admin db exists
        puts "#{Time.zone.now}: Unable to post public announcement.  #{error.message}"
      end
    end

    def self.populate_long_term(string)
      begin
        new(:description=>string,:is_sticky=>true).save!
      rescue => error
        puts "#{Time.zone.now}: Unable to post public announcement.  #{error.message}"
      end
    end

    def self.clear_load_message
      begin
        where('is_sticky is not true').each{|pa|pa.destroy}
      rescue => error
        puts "#{Time.zone.now}: Unable to clear public announcement.  #{error.message}"
      end
    end
  end
end

