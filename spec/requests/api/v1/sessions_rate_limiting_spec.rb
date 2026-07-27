# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Sessions rate limiting', type: :request do
  around do |example|
    Rack::Attack.enabled = true
    example.run
    Rack::Attack.enabled = false
  end

  before { Rack::Attack.cache.store.clear }

  it 'throttles repeated login attempts from the same ip' do
    create(:user, username: 'ignacio', password: '12345678')

    5.times do
      post '/api/v1/session', params: { username: 'ignacio', password: 'wrong-password' }
      expect(response).to have_http_status(:unauthorized)
    end

    post '/api/v1/session', params: { username: 'ignacio', password: 'wrong-password' }

    expect(response).to have_http_status(:too_many_requests)
    expect(response.parsed_body['error']).to eq('Too many login attempts. Please try again later.')
  end

  it 'does not throttle requests to other endpoints' do
    6.times { get '/api/v1/me' }

    expect(response).to have_http_status(:unauthorized)
  end
end
