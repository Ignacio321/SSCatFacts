# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  describe 'POST /api/v1/users' do
    context 'with valid params' do
      it 'creates a user and returns 201' do
        expect do
          post '/api/v1/users', params: { user: { username: 'ignacio', password: '12345678' } }
        end.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response.parsed_body['username']).to eq('ignacio')
      end
    end

    context 'with a short password' do
      it 'returns 422 with errors' do
        post '/api/v1/users', params: { user: { username: 'ignacio', password: 'short' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['errors']).to be_present
      end
    end

    context 'with a duplicated username' do
      it 'returns 422' do
        create(:user, username: 'ignacio')
        post '/api/v1/users', params: { user: { username: 'Ignacio', password: '12345678' } }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
