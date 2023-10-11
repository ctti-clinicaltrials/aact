require 'csv'

class BackgroundJob::DbQuery < BackgroundJob
  has_one_attached :result

  def process
    update(status: 'working')
    begin
      # run the SQL Query
      db = Util::DbManager.new
      @results = db.public_connection.execute(data['query'])
    
      # write out the query result to a csv file
      # get headers from the keys of query results to generate first line of csv file
      headers = (@results.first || []).map { |key,value| key }
      csv = CSV.generate_line headers
         
      # get rows from the values of the keys of query results to generate rest of lines of csv file
      @results.each do |line|
        rows = line.each.map { |key,value| value }
        csv << CSV.generate_line(rows)
      end
      
      # create a temporary directory "tmp" unless it already exists
      Dir.mkdir('tmp') unless Dir.exists?('tmp')

      filename = "tmp/#{id}.csv"

      f = File.open(filename, 'w')
      f << csv
      f.close

      # attach the csv file to the Background Job 
      result.attach(io: File.open(filename), filename: filename)

      # upload the query results to the cloud
      # add metadata information to the BackgroundJob
      # *** we need to add a column type json to store the number of rows from the query ***
      update(
        status: "complete",
        completed_at: Time.now,
        url: result.service.send(:object_for, result.key).public_url
      )
    
    # if there is an error in the SQL Query, show the error message
    rescue ActiveRecord::StatementInvalid => e
      user_error_message = [e.message]
      update(status: "error", logs: e.message, user_error_message: e.message)  
        
    # if the background job status is "error", show the user error message
    rescue StandardError => e
      update(status: "error", logs: e.message, user_error_message: "There was an error, please contact us.")
    end    
  end  
end    
