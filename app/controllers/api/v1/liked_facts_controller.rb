# frozen_string_literal: true

module Api
  module V1
    class LikedFactsController < ApplicationController
      PER_PAGE = 10

      before_action :require_authentication!

      def index
        render json: {
          facts: paginated_likes.map { |like| like_fact_json(like) },
          current_page: requested_page,
          last_page: last_page
        }
      end

      private

      def all_likes
        @all_likes ||= current_user.likes.includes(:fact).order(created_at: :desc)
      end

      def paginated_likes
        all_likes.offset((requested_page - 1) * PER_PAGE).limit(PER_PAGE)
      end

      def last_page
        [(all_likes.count.to_f / PER_PAGE).ceil, 1].max
      end

      def requested_page
        @requested_page ||= [(params[:page] || 1).to_i, 1].max
      end

      def like_fact_json(like)
        { like_id: like.id, text: like.fact.text, length: like.fact.length }
      end
    end
  end
end
