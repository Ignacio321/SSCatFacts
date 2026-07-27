# frozen_string_literal: true

module Api
  module V1
    class PopularFactsController < ApplicationController
      LIMIT = 10

      before_action :require_authentication!

      def index
        render json: { facts: popular_facts.map { |fact| fact_json(fact) } }
      end

      private

      def popular_facts
        Fact.left_joins(:likes)
            .select('facts.*, COUNT(likes.id) AS likes_count')
            .group(:id)
            .order(Arel.sql('COUNT(likes.id) DESC'))
            .limit(LIMIT)
      end

      def fact_json(fact)
        { text: fact.text, length: fact.length, likes_count: fact.likes_count.to_i }
      end
    end
  end
end
