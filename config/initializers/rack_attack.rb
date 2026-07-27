# frozen_string_literal: true

module Rack
  class Attack
    # A process-local store keeps this simple and dependency-free; since this
    # app runs as a single instance, it doesn't need a shared store like Redis.
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

    throttle('login attempts by ip', limit: 5, period: 20) do |req|
      req.ip if req.path == '/api/v1/session' && req.post?
    end

    self.throttled_responder = lambda do |_request|
      body = { error: 'Too many login attempts. Please try again later.' }.to_json
      [429, { 'Content-Type' => 'application/json' }, [body]]
    end
  end
end
