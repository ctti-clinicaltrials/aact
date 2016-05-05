class StatManager

	def self.generate_statistics
		Statistics.destroy_all!
	end

end

