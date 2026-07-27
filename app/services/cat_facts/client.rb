# frozen_string_literal: true

module CatFacts
  class Client
    BASE_URL = 'https://catfact.ninja'
    class Error < StandardError
    end

    def initialize(connection: default_connection)
      @connection = connection
    end

    # Returns an array of { text:, length: } hashes
    def fetch_facts(limit: 10)
      response = @connection.get('/facts', limit: limit)
      raise Error, "Unexpected status #{response.status}" unless response.success?

      parse_facts(response.body)
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

    def parse_facts(body)
      facts = body.fetch('data', [])
      facts.map { |fact| { text: fact['fact'], length: fact['length'] } }
    end
  end
end
