# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Likes', type: :request do
  let(:user) { create(:user, username: 'ignacio', password: '12345678') }

  def login_as(user)
    post '/api/v1/session', params: { username: user.username, password: '12345678' }
  end

  describe 'POST /api/v1/likes' do
    context 'when not authenticated' do
      it 'returns 401' do
        post '/api/v1/likes', params: { fact: { text: 'Cats sleep a lot.', length: 17 } }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      before { login_as(user) }

      it 'creates the fact and the like' do
        expect do
          post '/api/v1/likes', params: { fact: { text: 'Cats sleep a lot.', length: 17 } }
        end.to change(Fact, :count).by(1).and change(Like, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response.parsed_body['fact']['text']).to eq('Cats sleep a lot.')
      end

      it 'reuses an existing fact with the same text' do
        fact = create(:fact, text: 'Cats sleep a lot.', length: 17)

        expect do
          post '/api/v1/likes', params: { fact: { text: fact.text, length: fact.length } }
        end.to change(Fact, :count).by(0).and change(Like, :count).by(1)
      end

      it 'is idempotent when the fact is already liked' do
        fact = create(:fact)
        like = create(:like, user: user, fact: fact)

        expect do
          post '/api/v1/likes', params: { fact: { text: fact.text, length: fact.length } }
        end.not_to change(Like, :count)

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['id']).to eq(like.id)
      end
    end
  end

  describe 'DELETE /api/v1/likes/:id' do
    context 'when not authenticated' do
      it 'returns 401' do
        delete '/api/v1/likes/1'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      before { login_as(user) }

      it 'removes the like' do
        like = create(:like, user: user)

        expect { delete "/api/v1/likes/#{like.id}" }.to change(Like, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end

      it 'returns 404 for a like belonging to another user' do
        other_like = create(:like)

        delete "/api/v1/likes/#{other_like.id}"

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
