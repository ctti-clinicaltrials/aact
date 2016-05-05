  class Facility < StudyRelationship
		attr_accessor :coordinates

    def self.create_all_from(opts)
      all=opts[:xml]
      results=all.xpath("//location").collect{|wrapper1|
				opts[:wrapper1_xml]=wrapper1
				wrapper1.xpath("facility").collect{|xml|
				opts[:xml]=xml
				new.create_from(opts)
				}
      }.flatten!
      if results.nil?
        []
      else
        results
      end
    end

    def attribs
      {
      :name => get('name'),
      :city => get_addr('city'),
      :state => get_addr('state'),
      :zip => get_addr('zip'),
      :country => get_addr('country'),
      :status => get_from_wrapper1('status'),
      :contact_name => get_from('contact','last_name'),
      :contact_phone => get_from('contact','phone'),
      :contact_email => get_from('contact','email'),
      :contact_backup_name => get_from('contact_backup','last_name'),
      :contact_backup_phone => get_from('contact_backup','phone'),
      :contact_backup_email => get_from('contact_backup','email'),
      :investigator_name => get_from('investigator','last_name'),
      :investigator_role => get_from('investigator','role'),
      :latitude => get_latitude,
      :longitude => get_longitude,
      }
    end

    def get_from(sublevel,label)
      elem=wrapper1_xml.xpath(sublevel).try(:xpath,label)
      elem.inner_html if elem
    end

    def get_addr(label)
      elem=xml.xpath('address').try(:xpath,label)
      elem.inner_html if elem
    end

		def formatted_addr
			address.tr(' ','+') if address
		end

		def address
			"#{name}, #{city}, #{state}, #{country}"
		end

		def coordinates
			@coordinates ||= Asker.get_coordinates(formatted_addr)
		end

		def get_latitude
			coordinates[:latitude]
		end

		def get_longitude
			coordinates[:longitude]
		end

		def fix_coordinates
			self.latitude=get_latitude
			self.longitude=get_longitude
			self.save!
		end

  end
