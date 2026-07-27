# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatFacts::Client do
  subject(:client) { described_class.new }

  describe '#fetch_facts' do
    it 'returns facts mapped to text and length, with pagination metadata' do
      stub_request(:get, 'https://catfact.ninja/facts')
        .with(query: { limit: 10, page: 1 })
        .to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: {
            data: [
              { fact: 'Cats sleep 70% of their lives.', length: 30 },
              { fact: 'A group of cats is a clowder.', length: 29 }
            ],
            current_page: 1,
            last_page: 34
          }.to_json
        )

      result = client.fetch_facts

      expect(result[:facts]).to contain_exactly(
        { text: 'Cats sleep 70% of their lives.', length: 30 },
        { text: 'A group of cats is a clowder.', length: 29 }
      )
      expect(result[:current_page]).to eq(1)
      expect(result[:last_page]).to eq(34)
    end

    it 'requests the given page' do
      stub_request(:get, 'https://catfact.ninja/facts')
        .with(query: { limit: 10, page: 2 })
        .to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: { data: [], current_page: 2, last_page: 34 }.to_json
        )

      result = client.fetch_facts(page: 2)

      expect(result[:current_page]).to eq(2)
    end

    it 'raises a client error on server errors' do
      stub_request(:get, 'https://catfact.ninja/facts')
        .with(query: { limit: 10, page: 1 })
        .to_return(status: 500)

      expect { client.fetch_facts }.to raise_error(CatFacts::Client::Error)
    end

    it 'raises a client error on timeouts' do
      stub_request(:get, 'https://catfact.ninja/facts')
        .with(query: { limit: 10, page: 1 })
        .to_timeout

      expect { client.fetch_facts }.to raise_error(CatFacts::Client::Error, /unavailable/)
    end
  end
end
