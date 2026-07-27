# frozen_string_literal: true

module CatFacts
  class Client
    BASE_URL = 'https://catfact.ninja'
    class Error < StandardError
    end

    def initialize(connection: default_connection)
      @connection = connection
    end

    # Returns { facts: [{ text:, length: }], current_page:, last_page: }
    def fetch_facts(limit: 10, page: 1)
      response = @connection.get('/facts', limit: limit, page: page)
      raise Error, "Unexpected status #{response.status}" unless response.success?

      parse_response(response.body)
    rescue Faraday::Error => e
      raise Error, "Cat facts API unavailable: #{e.message}"
    end

    private

    def default_connection
      Faraday.new(url: BASE_URL) do |f|
        f.response :json
        f.options.timeout = 5
        f.options.open_timeout = 2
      end
    end

    def parse_response(body)
      facts = body.fetch('data', []).map { |fact| { text: fact['fact'], length: fact['length'] } }
      { facts: facts, current_page: body['current_page'], last_page: body['last_page'] }
    end
  end
end
