class CalculatedValue < ActiveRecord::Base
  belongs_to :study, :foreign_key => 'nct_id'

  def self.populate(nct_ids)

    # TODO: possibly validate nct_ids

    # Populate the table with initial values for the valid nct_ids
    insert_or_update_initial_values(nct_ids)


    # Run the following methods to update the table
    self.ruby_methods.each{|method|
      log_execution_time(method, nct_ids)
    } 

  end

  # Method to log execution time of a query
  def self.log_execution_time(method, nct_ids)
    start_time = Time.now
    send(method, nct_ids)

    end_time = Time.now
    duration = end_time - start_time
    puts "#{method} executed in #{duration} seconds".green
  end


  def self.ruby_methods
    [
      :update_were_results_reported
    ]
  end

  private


  def self.insert_or_update_initial_values(nct_ids)
    nct_ids.each do |nct_id|
      CalculatedValue.find_or_create_by(nct_id: nct_id)
    end
  end

  def self.update_were_results_reported(nct_ids)
    reported_nct_ids = Outcome.where(nct_id: nct_ids).distinct.pluck(:nct_id)
    # TODO: is default value false?
    CalculatedValue.where(nct_id: reported_nct_ids).update_all(were_results_reported: true)
  end
end
