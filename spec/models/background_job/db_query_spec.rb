require 'rails_helper'

RSpec.describe BackgroundJob::DbQuery, type: :model do
  context '#process' do
    it 'should complete successfully when there is a valid SQL query' do
      job = FactoryBot.create(:background_job_db_query)
      job.process
      expect(job.status).to eq('complete')
      expect(job.result.attached?).to eq(true)
      expect(job.url).not_be be_nil

    end
    it 'should update the status to "error" for the user when the SQL query is invalid' do
      job = FactoryBot.create(:background_job_db_query, data: { 'query' => 'SELECT * count studies' })
      job.process
      expect(job.status).to eq('error')
      expect(job.user_error_message).to eq('PG::SyntaxError: ERROR:  syntax error at or near \"count\"\nLINE 1: SELECT * count studies\n                 ^\n')
    end  
  end  
end