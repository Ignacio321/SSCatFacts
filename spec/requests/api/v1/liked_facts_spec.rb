# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::LikedFacts', type: :request do
  describe 'GET /api/v1/liked_facts' do
    context 'when not authenticated' do
      it 'returns 401' do
        get '/api/v1/liked_facts'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      let(:user) { create(:user, username: 'ignacio', password: '12345678') }

      before { post '/api/v1/session', params: { username: user.username, password: '12345678' } }

      it 'returns only the facts liked by the current user' do
        liked_fact = create(:fact, text: 'Cats have five toes on their front paws.')
        create(:like, user: user, fact: liked_fact)
        create(:like, fact: create(:fact))

        get '/api/v1/liked_facts'

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['facts'].pluck('text')).to eq([liked_fact.text])
        expect(response.parsed_body['current_page']).to eq(1)
        expect(response.parsed_body['last_page']).to eq(1)
      end

      it 'paginates the results' do
        create_list(:fact, 15).each { |fact| create(:like, user: user, fact: fact) }

        get '/api/v1/liked_facts'

        expect(response.parsed_body['facts'].size).to eq(10)
        expect(response.parsed_body['last_page']).to eq(2)

        get '/api/v1/liked_facts', params: { page: 2 }

        expect(response.parsed_body['facts'].size).to eq(5)
        expect(response.parsed_body['current_page']).to eq(2)
      end
    end
  end
end
