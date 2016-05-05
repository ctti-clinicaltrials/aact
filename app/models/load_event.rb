	class LoadEvent < ActiveRecord::Base
		attr_accessor :start_time

		def start_clock
			@start_time=Time.now
		end

		def complete
			self.status='complete'
			self.load_time=(Time.now - start_time)
			self.save!
		end

	end
