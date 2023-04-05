require 'csv'

class BackgroundJob::Query < BackgroundJob
  has_one_attached :result

  def process
    update(status: 'working')
    begin
      # run the SQL Query
      @results = PublicBase.execute(data)
    
      # write out the query result to a csv file
      # get headers from the keys of query results to generate first line of csv file
      headers = @results.first.map { |key,value| key }
      csv = CSV.generate_line headers
         
      # get rows from the values of the keys of query results to generate rest of lines of csv file
      @results.each do |line|
        rows = line.each.map { |key,value| value }
        csv << CSV.generate_line(rows)
      end
      
      filename = "tmp/#{id}.csv"

      f = File.open(filename, 'W')
      f << csv
      f.close

      # attach the csv file to the Background Job 
      result.attach(io: File.open(filename), filename: filename)

      # upload the query results to the cloud
      # *** add metadata information to the BackgroundJob (the number of rows from the query), 
      # I think we need to add a column type json to store that ***
      update(
        status: "complete",
        completed_at: Time.now,
        url: result.service.send(:object_for, result.key).public_url
      )
    # if there is an error in the SQL Query, display the form again with the error message
    rescue StandardError => e
      update(status: "error", message: e.message)
    end
    # rescue ActiveRecord::StatementInvalid => e
    #   @error = [e.message]
    #   update(status: "error", message: e.message)
    # end
  end  
end    