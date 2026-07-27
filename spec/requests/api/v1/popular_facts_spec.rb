# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::PopularFacts', type: :request do
  describe 'GET /api/v1/popular_facts' do
    context 'when not authenticated' do
      it 'returns 401' do
        get '/api/v1/popular_facts'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      before do
        create(:user, username: 'ignacio', password: '12345678')
        post '/api/v1/session', params: { username: 'ignacio', password: '12345678' }
      end

      it 'orders facts by likes count, descending' do
        most_liked = create(:fact, text: 'Most liked fact')
        create_list(:like, 3, fact: most_liked)
        least_liked = create(:fact, text: 'Least liked fact')
        create(:like, fact: least_liked)
        unliked = create(:fact, text: 'Unliked fact')

        get '/api/v1/popular_facts'

        texts = response.parsed_body['facts'].pluck('text')
        expect(texts).to eq([most_liked.text, least_liked.text, unliked.text])
      end

      it 'includes the likes count for each fact' do
        fact = create(:fact)
        create_list(:like, 2, fact: fact)

        get '/api/v1/popular_facts'

        expect(response.parsed_body['facts'].first['likes_count']).to eq(2)
      end

      it 'limits the results to the top 10 facts' do
        create_list(:fact, 15)

        get '/api/v1/popular_facts'

        expect(response.parsed_body['facts'].size).to eq(10)
      end
    end
  end
end
