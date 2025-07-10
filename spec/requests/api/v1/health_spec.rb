require 'rails_helper'

RSpec.describe 'Api::V1::Health', type: :request do
  describe 'GET /api/v1/health' do
    it 'returns health status with services information' do
      get '/api/v1/health'

      expect(response).to have_http_status(:ok)
      expect(json_response).to include(
        'status' => be_in(%w[healthy degraded unhealthy]),
        'timestamp' => be_present,
        'services' => be_a(Hash)
      )
    end

    it 'includes database service status' do
      get '/api/v1/health'

      expect(json_response['services']).to include(
        'database' => include('status' => be_in(%w[healthy unhealthy]))
      )
    end

    it 'includes redis service status' do
      get '/api/v1/health'

      expect(json_response['services']).to include(
        'redis' => include('status' => be_in(%w[healthy unhealthy]))
      )
    end

    it 'includes sidekiq service status' do
      get '/api/v1/health'

      expect(json_response['services']).to include(
        'sidekiq' => include('status' => be_in(%w[healthy unhealthy]))
      )
    end

    it 'returns healthy status when all services are healthy' do
      allow_any_instance_of(Api::V1::HealthController).to receive(:check_database).and_return({ status: 'healthy', response_time: '1.5ms' })
      allow_any_instance_of(Api::V1::HealthController).to receive(:check_redis).and_return({ status: 'healthy', response_time: '0.5ms' })
      allow_any_instance_of(Api::V1::HealthController).to receive(:check_sidekiq).and_return({ status: 'healthy', processes: 1 })

      get '/api/v1/health'

      expect(json_response['status']).to eq('healthy')
    end
  end
end
