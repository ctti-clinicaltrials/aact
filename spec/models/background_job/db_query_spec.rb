require 'rails_helper'

RSpec.describe BackgroundJob::DbQuery, type: :model do
  before do
    stub_request(:put, /https:\/\/aact-dev.nyc3.digitaloceanspaces.com\/.*/).to_return(:status => 200, :body => '', :headers => {})
    # TODO: Review based on transition ctgov -> ctgov_v2 approach
    ActiveRecord::Base.connection.schema_search_path = 'ctgov, support, public'
  end

  context '#process' do
    it 'should complete successfully when there is a valid SQL query' do
      job = FactoryBot.create(:background_job_db_query)
      job.process
      expect(job.status).to eq('complete')
      expect(job.result.attached?).to eq(true)
      expect(job.url).not_to be_nil
    end
    
    it 'should update the status to "error" for the user when the SQL query is invalid' do
      job = FactoryBot.create(:background_job_db_query, data: { 'query' => 'SELECT * count studies' })
      job.process
      expect(job.status).to eq('error')
      expect(job.user_error_message).to match(/syntax error at or near/)
    end  
  end  
end