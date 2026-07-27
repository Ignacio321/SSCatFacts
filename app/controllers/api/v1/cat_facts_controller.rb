# frozen_string_literal: true

module Api
  module V1
    class CatFactsController < ApplicationController
      before_action :require_authentication!

      def index
        facts = cat_facts_client.fetch_facts
        render json: { facts: facts }
      rescue CatFacts::Client::Error
        render json: { error: 'Cat facts are unavailable right now' }, status: :service_unavailable
      end

      private

      def cat_facts_client
        @cat_facts_client ||= CatFacts::Client.new
      end
    end
  end
end
