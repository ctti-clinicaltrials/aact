require 'csv'
#require 'active_support/all'
#  received input file from Scott Dempwolf of UofMD who got it from ian.barber@fda.hhs.gov
#module OpenTrials
	class PmaMapping < ActiveRecord::Base
		#establish_connection "open_#{Rails.env}".to_sym
		belongs_to :study, :foreign_key=> 'nct_id'

		def self.load(file_name='public/other_data/pma_mappings.csv')
			CSV.foreach(file_name,
					:headers 		 => true,
					:col_sep 		 => ',',
					:skip_blanks => true,
					:converters  => :all,
					:header_converters => lambda {|h|h.try(:underscore)}) do |row|
				incoming_row=row.to_hash
				incoming_row.delete(nil)
				incoming_row.delete('NULL')
				uid=Digest::SHA1.hexdigest(incoming_row.to_s)
				if self.where('unique_id=?',uid).size > 0
					puts "Duplicate Not Loaded: #{incoming_row}"
				else
					self.create!(incoming_row)
				end
			end
		end

	end
#end
