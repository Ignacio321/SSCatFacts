# frozen_string_literal: true

module Api
  module V1
    class CatFactsController < ApplicationController
      before_action :require_authentication!

      def index
        render json: cat_facts_client.fetch_facts(page: requested_page)
      rescue CatFacts::Client::Error
        render json: { error: 'Cat facts are unavailable right now' }, status: :service_unavailable
      end

      private

      def requested_page
        (params[:page] || 1).to_i
      end

      def cat_facts_client
        @cat_facts_client ||= CatFacts::Client.new
      end
    end
  end
end
