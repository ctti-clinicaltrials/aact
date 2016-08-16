require 'rails_helper'

describe AACT2::V1::AppAPI do
  let(:json_headers) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json'} }

  describe 'app status', :vcr do
    subject { get '/api/v1/app/status', json_headers }

    context 'when rdbms is not connected' do
      it 'should return response.status 503' do
        expect(ActiveRecord::Base.connection).to receive(:active?).and_return(false)
        is_expected.to eq(503)
        expect(response.body).to be
        expect(response.body).not_to eq('null')
        returned_configs = JSON.parse(response.body)
        expect(returned_configs).to be_a Hash
        expect(returned_configs).to have_key('status')
        expect(returned_configs['status']).to eq('error')
        expect(returned_configs).to have_key('rdbms')
        expect(returned_configs['rdbms']).to eq('is not connected')
      end
    end #when rdbms not connected

    context 'when redis is not connected' do
      it 'should return response.status 503' do
        expect_any_instance_of(Redis).to receive(:info).and_raise(SocketError, 'getaddrinfo: Name or service not known')
        is_expected.to eq(503)
        expect(response.body).to be
        expect(response.body).not_to eq('null')
        returned_configs = JSON.parse(response.body)
        expect(returned_configs).to be_a Hash
        expect(returned_configs).to have_key('status')
        expect(returned_configs['status']).to eq('error')
        expect(returned_configs).to have_key('keystore')
        expect(returned_configs['keystore']).to eq('is not connected')
      end
    end #redis

    context 'when properly integrated' do
      before do
        WebMock.reset!
      end

    end #when properly integrated
  end #app status
end
