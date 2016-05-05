#require 'active_support/all'
#module OpenTrial
	class PmaRecord < ActiveRecord::Base
		attr_accessor :data
		#establish_connection "open_#{Rails.env}".to_sym
		belongs_to :study, :foreign_key=> 'nct_id'

		def create_from(incoming_data)
			@data=incoming_data
			uid=Digest::SHA1.hexdigest(data.to_s)
			if PmaRecord.where('unique_id=?',uid).size > 0
				puts "Duplicate Not Loaded: #{data}"
			else
				update_attributes(attribs.merge({:unique_id=>uid}))
				return self
			end
		end

		def attribs
			{
				:last_updated => data['meta']['last_updated'],
				:pma_number => data['results'].first["pma_number"],
				:supplement_number => data['results'].first["supplement_number"],
				:supplement_type => data['results'].first["supplement_type"],
				:supplement_reason => data['results'].first["supplement_reason"],
				:applicant => data['results'].first["applicant"].split(' ').collect(&:capitalize).join(' '),
				:street_1 => data['results'].first["street_1"],
				:street_2 => data['results'].first["street_2"],
				:city => data['results'].first["city"],
				:state => data['results'].first["state"],
				:zip => data['results'].first["zip"],
				:zip_ext => data['results'].first["zip_ext"],
				:date_received => data['results'].first["date_received"],
				:decision_date => data['results'].first["decision_date"],
				:decision_code => data['results'].first["decision_code"],
				:expedited_review_flag => data['results'].first["expedited_review_flag"],
				:advisory_committee => data['results'].first["advisory_committee"],
				:advisory_committee_description => data['results'].first["advisory_committee_description"],
				:device_name => data['results'].first["openfda"]['device_name'],
				:device_class => data['results'].first["openfda"]['device_class'],
				:trade_name => data['results'].first["trade_name"].split(' ').collect(&:capitalize).join(' '),
				:product_code => data['results'].first["product_code"],
				:generic_name => data['results'].first["generic_name"].split(' ').collect(&:capitalize).join(' '),
				:medical_specialty_description => data['results'].first["openfda"]['medical_specialty_description'],
				:docket_number => data['results'].first["docket_number"],
				:regulation_number => data['results'].first["openfda"]['regulation_number'],
				:fei_numbers => data['results'].first["openfda"]['fei_number'].join(','),
				:registration_numbers => data['results'].first["openfda"]['registration_number'].join(','),
				:ao_statement => data['results'].first['ao_statement'].split(' ').collect(&:capitalize).join(' ')
			}
		end

	end
#	end
