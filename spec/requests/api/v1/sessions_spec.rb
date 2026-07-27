# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Sessions', type: :request do
  let!(:user) { create(:user, username: 'ignacio', password: '12345678') }

  describe 'POST /api/v1/session' do
    it 'logs in with valid credentials' do
      post '/api/v1/session', params: { username: 'ignacio', password: '12345678' }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['username']).to eq('ignacio')
    end

    it 'is case-insensitive for the username' do
      post '/api/v1/session', params: { username: 'IGNACIO', password: '12345678' }

      expect(response).to have_http_status(:ok)
    end

    it 'rejects invalid credentials' do
      post '/api/v1/session', params: { username: 'ignacio', password: 'wrongpass' }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'rejects unknown users with the same error' do
      post '/api/v1/session', params: { username: 'ghost', password: '12345678' }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/me' do
    it 'returns the current user when logged in' do
      post '/api/v1/session', params: { username: 'ignacio', password: '12345678' }
      get '/api/v1/me'

      expect(response.parsed_body['username']).to eq('ignacio')
    end

    it 'returns 401 when not logged in' do
      get '/api/v1/me'

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /api/v1/session' do
    it 'logs out' do
      post '/api/v1/session', params: { username: 'ignacio', password: '12345678' }
      delete '/api/v1/session'
      get '/api/v1/me'

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
