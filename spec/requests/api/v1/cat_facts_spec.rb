# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::CatFacts', type: :request do
  describe 'GET /api/v1/cat_facts' do
    context 'when not authenticated' do
      it 'returns 401' do
        get '/api/v1/cat_facts'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      before do
        create(:user, username: 'ignacio', password: '12345678')
        post '/api/v1/session', params: { username: 'ignacio', password: '12345678' }
      end

      it 'returns the facts from the external api with pagination metadata' do
        stub_request(:get, 'https://catfact.ninja/facts')
          .with(query: { limit: 10, page: 1 })
          .to_return(
            status: 200,
            headers: { 'Content-Type' => 'application/json' },
            body: { data: [{ fact: 'Cats purr at 26 hertz.', length: 22 }], current_page: 1, last_page: 34 }.to_json
          )

        get '/api/v1/cat_facts'

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['facts'].first['text']).to eq('Cats purr at 26 hertz.')
        expect(response.parsed_body['current_page']).to eq(1)
        expect(response.parsed_body['last_page']).to eq(34)
      end

      it 'requests the given page' do
        stub_request(:get, 'https://catfact.ninja/facts')
          .with(query: { limit: 10, page: 3 })
          .to_return(
            status: 200,
            headers: { 'Content-Type' => 'application/json' },
            body: { data: [], current_page: 3, last_page: 34 }.to_json
          )

        get '/api/v1/cat_facts', params: { page: 3 }

        expect(response.parsed_body['current_page']).to eq(3)
      end

      it 'returns 503 when the external api fails' do
        stub_request(:get, 'https://catfact.ninja/facts')
          .with(query: { limit: 10, page: 1 })
          .to_return(status: 500)

        get '/api/v1/cat_facts'

        expect(response).to have_http_status(:service_unavailable)
      end
    end
  end
end
